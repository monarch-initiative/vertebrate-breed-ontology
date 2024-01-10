import argparse
import csv
import logging
from typing import TextIO

import pandas as pd

from dadis_client import DadisClient

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")


def full_local_match_workflow(
    input_filename: str, output_filename: str, dadis_api_key: str
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

    logger.info(f"Writing output file to {output_filename}:")
    output_file = create_output_tsv(
        input_filename=input_filename,
        output_filename=output_filename,
        extra_cols=[
            "dadis_breed_id",
            "dadis_transboundary_id",
            "dadis_update_date",
        ],
    )
    matched_breeds.to_csv(output_file, sep="\t", index=False, header=False)
    output_file.close()
    logger.info("Output written.")
    return matched_breeds


def read_vbo_data(filename: str) -> pd.DataFrame:
    vbo_breeds = pd.read_table(
        filename, sep="\t", skiprows=[1], low_memory=False
    ).convert_dtypes()
    logger.warning(
        "Fixing swapped column names: dadis_species_name, dadis_country. Remove this code when input data is fixed"
    )
    country = vbo_breeds["dadis_species_name"].copy()
    species = vbo_breeds["dadis_country"].copy()
    vbo_breeds["dadis_country"] = country
    vbo_breeds["dadis_species_name"] = species
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


def create_output_tsv(
    input_filename: str, output_filename: str, extra_cols: list[str] = None
) -> TextIO:
    """
    Copy the 2 header lines from the input file to the output file. Return
    a file object for the output file, so pandas can write the rest of the file
    """
    file_out = open(output_filename, "w")
    csv_out = csv.writer(file_out, dialect="excel-tab")
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
    return file_out


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
    )

    args = parser.parse_args()
    logger.setLevel(args.log.upper())
    full_local_match_workflow(
        input_filename=args.input_filename,
        output_filename=args.output_filename,
        dadis_api_key=args.dadis_api_key,
    )
