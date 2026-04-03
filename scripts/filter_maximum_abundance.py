import pandas as pd
import sys
import argparse


def get_args():
    parser = argparse.ArgumentParser(description='Use filtered TSV files in pandas script')
    parser.add_argument("input", help="Insert TSV file")
    parser.add_argument("output", help="Output TSV file")
    parser.add_argument("--genus", required=True)
    parser.add_argument("--species", required=True)
    return parser.parse_args()

# Check if the species is desired species
def filter_species(df, genus_name, species_name):
    x = pd.Series(True, index=df.index)
    x &= df['Contig_name'].str.contains(f"{genus_name} {species_name}", case=False, na=False)
    return df[x]

def main():
    args = get_args()
    df = filter_species(df, args.genus, args.species)

# Read CSV file
    df = pd.read_csv(args.input, sep='\t')

# Filter the DataFrame
    filtered_df = df[df['Taxonomic_abundance'] > 96.0]

# Save to TSV file
    filtered_df.to_csv(args.output, sep='\t', index=False)

if __name__ == "__main__":
    main()
