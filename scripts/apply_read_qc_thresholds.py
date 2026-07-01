import pandas as pd
import sys
import argparse
import os


def get_args():
    parser = argparse.ArgumentParser(description='Combine data from sylph and fastp QC steps and identify reads that pass thresholds')
    parser.add_argument("sylph_input", help="TSV output from sylph with only top hits")
    parser.add_argument("fastp_input", help="TSV summary of fastp metrics")
    parser.add_argument("output_metrics", help="Output TSV file with combined read QC metrics")
    parser.add_argument("output_pass", help="Output file with list of samples that passed QC")
    parser.add_argument("--genus", required=True, help="Expected genus of samples in dataset")
    parser.add_argument("--species", required=True, help="Expected species of samples in dataset")
    parser.add_argument("--min_abundance", type=float, default=0, help="Minimum abundance of expected species in reads")
    parser.add_argument("--genome_size", type=int, required=True, help="Expected genome size")
    parser.add_argument("--min_coverage", type=int, default=20, help="Minimum estimated coverage of Q30 reads")
    return parser.parse_args()

# Check if the species is desired species
def filter_species(df, genus_name, species_name):
    x = pd.Series(True, index=df.index)
    x &= df['Contig_name'].str.contains(f"{genus_name} {species_name}", case=False, na=False)
    return df[x]

def main():
    args = get_args()

    # reorganize sylph output
    df_sylph = pd.read_csv(args.sylph_input, sep='\t')
    df_sylph['sample'] = df_sylph['Sample_file'].apply(os.path.basename).str.replace('_1.fastq.gz', '')
    df_sylph_target_species = filter_species(df_sylph, args.genus, args.species)
    df_sylph_final = df_sylph_target_species[['sample', 'Taxonomic_abundance']].rename(columns={'Taxonomic_abundance':'sylph_taxonomic_abundance'})

    # reorganize fastp output
    df_fastp = pd.read_csv(args.fastp_input, sep='\t')
    df_fastp['fastp_expected_q30_coverage'] = df_fastp['q30_bases_after_filtering']/args.genome_size
    df_fastp_final = df_fastp.rename(columns={'q30_bases_after_filtering':'fastp_q30_bases_after_filtering', 'gc_content_after_filtering':'fastp_gc_content_after_filtering'})

    # merge data frames
    merged_df = pd.merge(df_fastp_final, df_sylph_final, how='outer')
    merged_df.to_csv(args.output_metrics, sep = '\t', index=False)

    # filter samples based on metrics

    filtered_df = merged_df[(merged_df['sylph_taxonomic_abundance'] > args.min_abundance) & (merged_df['fastp_expected_q30_coverage'] > args.min_coverage)]
    filtered_samples = filtered_df['sample']
    filtered_samples.to_csv(args.output_pass, sep='\t', index=False)

if __name__ == "__main__":
    main()
