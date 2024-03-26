import argparse
import csv
import logging
import os
import shutil
from tempfile import NamedTemporaryFile
from typing import Optional, TextIO

import pandas as pd

from dadis_client import DadisClient

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")


def full_local_match_workflow(
    input_filename: str, output_filename: str, dadis_api_key: str,
    dadis_match_filename: Optional[str] = None
) -> pd.DataFrame:
    """
    Perform the full matching workflow:

    - Read VBO data from input_filename
    - Match to DADIS to get DADIS ids
    - Save to a new TSV file at output_filename
    """
    client = DadisClient(api_key=dadis_api_key)
    logger.info(f"Reading VBO entries from {input_filename}")
    vbo_data = read_vbo_data(input_filename)
    logger.info(f"Matching to DADIS data")
    matched_breeds = match_vbo_breeds(vbo_data=vbo_data, client=client)

    # We need to create a temporary file for the output, in case we're writing
    #   to the same filename as the input: we don't want
    #   to overwrite/clear the input file until we can read the header from it
    logger.info(f"Creating temporary output TSV:")
    with NamedTemporaryFile(mode="w", delete=False) as temp_out:
        write_tsv_header(
            input_filename=input_filename,
            output_file=temp_out,
            extra_cols=[
                "dadis_breed_id",
                "dadis_transboundary_id",
                "dadis_update_date",
            ],
        )
        matched_breeds = clean_output(matched_breeds)
        matched_breeds.to_csv(temp_out, sep="\t", index=False, header=False)
        temp_out.close()
        logger.info("Output written to temp file.")
        shutil.copy2(src=temp_out.name, dst=output_filename)
        logger.info(f"Copied to {output_filename}")

    if dadis_match_filename is not None:
        logger.info("Finding unmatched DADIS entries")
        dadis_unmatched = find_unmatched_dadis(vbo_output=matched_breeds, client=client)
        logger.info(f"Writing unmatched DADIS entries to {dadis_match_filename}")
        dadis_unmatched.to_csv(dadis_match_filename, sep="\t", index=False, header=True)
    return matched_breeds


def read_vbo_data(filename: str) -> pd.DataFrame:
    vbo_breeds = pd.read_table(
        filename,
        sep="\t",
        skiprows=[1],
        dtype={"obsolete": str, "description_of_origin": str},
        na_values=[],
        keep_default_na=False,
        low_memory=False
    ).convert_dtypes(
        infer_objects=False,
        convert_string=False,
        convert_boolean=False
    )
    return vbo_breeds


def get_dadis_species(client: DadisClient) -> pd.DataFrame:
    resp = client.get_all_species()
    all_species = []
    for s in resp.response:
        species = {"dadis_species_id": s.id, "dadis_species_name": s.name["en"]}
        all_species.append(species)
    return pd.DataFrame.from_records(all_species)


def get_dadis_all_breeds(client: DadisClient) -> pd.DataFrame:
    resp = client.get_all_breeds()
    df = (
        pd.DataFrame.from_records([breed.model_dump() for breed in resp.response])
        .convert_dtypes()
        .rename(
            columns={
                "id": "dadis_breed_id",
                "name": "dadis_breed_name",
                "iso3": "dadis_iso3_code",
                "speciesId": "dadis_species_id",
                "transboundaryId": "dadis_transboundary_id",
                "updatedAt": "dadis_update_date",
            }
        )
    )
    df["dadis_update_date"] = df["dadis_update_date"].map(
        lambda d: pd.to_datetime(d, unit="ms")
    )
    # Merge species information
    species_df = get_dadis_species(client)
    df = df.merge(species_df, how="left", on="dadis_species_id")
    return df


def match_vbo_breeds(vbo_data: pd.DataFrame, client: DadisClient) -> pd.DataFrame:
    """
    Match VBO breed entries to DADIS, based on breed name, species, and country (ISO3 code)
    """
    logger.info("Fetching DADIS breeds")
    dadis_all = get_dadis_all_breeds(client=client)
    merged = vbo_data.merge(
        dadis_all,
        how="left",
        left_on=["dadis_name", "dadis_species_name", "dadis_iso3_code"],
        right_on=["dadis_breed_name", "dadis_species_name", "dadis_iso3_code"],
        sort=False,
        indicator=True,
    )
    n_matched = merged["_merge"].eq("both").sum()
    n_total = len(merged["_merge"])
    logger.info(f"{n_matched} / {n_total} VBO breeds successfully matched to DADIS IDs")
    merged = merged.drop(columns=["_merge", "dadis_breed_name", "dadis_species_id"])
    return merged


def find_unmatched_dadis(vbo_output: pd.DataFrame, client: DadisClient) -> pd.DataFrame:
    """
    Merge all DADIS breeds with the already matched VBO data, to see how many DADIS entries
    match in the other direction
    """
    dadis_all = get_dadis_all_breeds(client)
    dadis_unmatched = (
        dadis_all
        .merge(vbo_output[["dadis_breed_id", "vbo_id"]], on="dadis_breed_id", how="left", indicator=True)
        .loc[lambda x: x._merge == "left_only"]
        .drop(columns=["_merge"])
    )
    return dadis_unmatched


def write_tsv_header(
    input_filename: str, output_file: TextIO, extra_cols: list[str] = None
):
    """
    Copy the two header lines from the input file to output_file, adding the columns in extra_cols
    """
    csv_out = csv.writer(output_file, dialect="excel-tab")
    with open(input_filename) as file_in:
        csv_in = csv.reader(file_in, dialect="excel-tab")
        for index, line in enumerate(range(2)):
            header = next(csv_in)
            if extra_cols is not None:
                if index == 0:
                    header += extra_cols
                if index == 1:
                    header += ["" for i in range(len(extra_cols))]
            csv_out.writerow(header)


def clean_output(df: pd.DataFrame) -> pd.DataFrame:
    """
    Clean the dataframe before writing

    * Convert any None values to empty strings
    """
    string_columns = df.select_dtypes(include="object").columns
    for column in string_columns:
        df[column] = df[column].fillna("")
    return df


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Find DADIS entries matching VBO breeds"
    )
    parser.add_argument("--log", help="Logging level", default="INFO")
    parser.add_argument(
        "--input_filename", help="Spreadsheet (TSV) with VBO local breeds"
    )
    parser.add_argument("--output_filename", help="Filename to save the updated TSV to")
    parser.add_argument(
        "--dadis_api_key",
        help="API key for DADIS API (private: should be stored in Github Secrets)",
        default=os.getenv("DADIS_API_KEY")
    )
    parser.add_argument(
        "--dadis_match_filename", help="Optional filename to write unmatched DADIS entries to",
        default=None
    )
    args = parser.parse_args()

    if args.dadis_api_key is None:
        raise ValueError("DADIS API key not set. Set the DADIS_API_KEY environment variable or use the --dadis_api_key argument")

    logger.setLevel(args.log.upper())
    full_local_match_workflow(
        input_filename=args.input_filename,
        output_filename=args.output_filename,
        dadis_api_key=args.dadis_api_key,
        dadis_match_filename=args.dadis_match_filename
    )
