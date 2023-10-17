import pandas as pd
import argparse

def main(input_filename: str):
    input_df = pd.read_excel(input_filename)
    return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Find DADIS entries matching VBO breeds")
    parser.add_argument("--input_filename", help="Spreadsheet with VBO transboundary breeds")

    args = parser.parse_args()
    main(input_filename=args.input_filename)
