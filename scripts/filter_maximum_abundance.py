import pandas as pd
import sys
import argparse


def get_args():
    parser = argparse.ArgumentParser(description='Use filtered TSV files in pandas script')
    parser.add_argument("input", help="Insert TSV file")
    parser.add_argument("output", help="Output TSV file")
    return parser.parse_args()

def main():
    args = get_args()

# Read CSV file
    df = pd.read_csv(args.input, sep='\t')

# Filter the DataFrame
    filtered_df = df[df['Taxonomic_abundance'] > 96.0]

# Check if the species is desired species
    

# Save to TSV file
    filtered_df.to_csv(args.output, sep='\t', index=False)

if __name__ == "__main__":
    main()
