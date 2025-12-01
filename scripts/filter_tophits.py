import sys
import numpy as np
import pandas as pd
import argparse

def get_args():
    parser = argparse.ArgumentParser(description='Use filtered TSV files in pandas script to get maximum value')
    parser.add_argument("input", help="Insert TSV file")
    parser.add_argument("output", help="Output TSV file")
    parser.add_argument("--genus", required=True)
    parser.add_argument("--species", required=True)
    return parser.parse_args()

def filter_species(df, genus_name, species_name):
    x = pd.Series(True, index=df.index)
    x &= df['Contig_name'].str.contains(f"{genus_name} {species_name}", case=False, na=False)
    return df[x]

def main():
    args = get_args()
    df = pd.read_csv(args.input, sep='\t')
    df = filter_species(df, args.genus, args.species)
    df = df.groupby('Sample_file').apply(pd.DataFrame.nlargest, n=1, columns='Taxonomic_abundance')
    df.to_csv(args.output, sep='\t', index=False)

if __name__ == "__main__":
    main()
