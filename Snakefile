import glob
import pandas as pd
from Bio import SeqIO

configfile: "config/config.yaml"

samples = pd.read_csv(config["samples"], sep="\t")
samples_dict = samples.set_index('sample').to_dict(orient="index")
include: "rules/download.smk"
include: "rules/reference_mapping.smk"
include: "rules/trees.smk"
include: "rules/assembly_annotation.smk"
include: "rules/amr.smk"
include: "rules/clustering.smk"

localrule: all

rule all:
    input:
        "data/trees/gubbins/core.final_tree.tre",
        expand("data/annotations/{sample}/{sample}.gff3", sample=samples["sample"]),
        "data/hamronize_summary.tsv",
        "data/poppunk/poppunk_clusters.csv"
