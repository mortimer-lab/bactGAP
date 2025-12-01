rule sylph:
    input:
       expand(["data/trimmed/{sample}_1.fastq.gz", "data/trimmed/{sample}_2.fastq.gz"], sample=samples["sample"]),
       "data/syl_db/gtdb-r220-c200-dbv1.syldb"
    output:
        "data/qc/sylph_profiles.tsv"
    conda:
        "../envs/sylph.yml"
    resources:
        runtime=90,
        mem_mb=32000
    shell:
        "sylph profile data/qc/gtdb-r220-c200-dbv1.syldb -1 data/trimmed/*_1.fastq.gz -2 data/trimmed/*_2.fastq.gz -t {threads} > {output}"

rule filter_tophits:
    input:
        "data/qc/sylph_profiles.tsv"
    output:
        "data/qc/sylph_profiles_tophits.tsv"
    conda:
        "../envs/pandas.yml"
    resources:
        runtime=90,
        mem_mb=32000
    shell:
        """
        python3 scripts/filter_tophits.py {input} {output} --genus "Treponema" --species "pallidum"
        """

rule filter_minimum_contamination:
    input:
        "data/qc/sylph_profiles_tophits.tsv"
    output:
        "data/qc/filtered_output.tsv"
    conda:
        "../envs/pandas.yml"
    resources:
        runtime=90,
        mem_mb=32000
    shell:
        """
        python3 scripts/filter_maximum_abundance.py {input} {output}
        """
