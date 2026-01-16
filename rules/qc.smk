rule sylph:
    input:
       fastqs=expand(["data/trimmed/{sample}_1.fastq.gz", "data/trimmed/{sample}_2.fastq.gz"], sample=samples["sample"]),
       db="data/syl_db/gtdb-r220-c200-dbv1.syldb"
    output:
        "data/qc/sylph_profiles.tsv"
    conda:
        "../envs/sylph.yml"
    threads: 12
    resources:
        runtime=lambda wildcards, attempt: attempt * 90,
        mem_mb=32000
    shell:
        "sylph profile {input.db} -1 data/trimmed/*_1.fastq.gz -2 data/trimmed/*_2.fastq.gz -t {threads} > {output}"

rule filter_tophits:
    input:
        "data/qc/sylph_profiles.tsv"
    output:
        "data/qc/sylph_profiles_tophits.tsv"
    shell:
        """
        python3 scripts/filter_tophits.py {input} {output} --genus "Treponema" --species "pallidum"
        """

rule filter_minimum_contamination:
    input:
        "data/qc/sylph_profiles_tophits.tsv"
    output:
        "data/qc/filtered_output.tsv"
    shell:
        """
        python3 scripts/filter_maximum_abundance.py {input} {output}
        """

rule checkm2:
    input:
        assemblies=expand(["data/filtered_assemblies/{sample}_contigs_filtered.fa"], sample=samples["sample"]),
        db="data/CheckM2_database/uniref100.KO.1.dmnd"
    output:
        "data/qc/checkm2/quality_report.tsv"
    threads: 16
    conda:
        "../envs/checkm2.yml"
    resources:
        runtime=lambda wildcards, attempt: attempt * 240,
        mem_mb=32000
    shell:
        """
        checkm2 predict --force -t {threads} -x .fa --output-directory data/qc/checkm2/ --input data/filtered_assemblies/ --database_path {input.db}
        """

rule quast:
    input:
        assemblies=expand(["data/filtered_assemblies/{sample}_contigs_filtered.fa"], sample=samples["sample"]),
    output:
        "data/qc/quast/transposed_report.tsv"
    threads: 16
    conda:
        "../envs/quast.yml"
    resources:
        runtime=lambda wildcards, attempt: attempt * 30,
        mem_mb=8000
    shell:
        """
        quast -o data/qc/quast --threads 16 --no-plots {input.assemblies}
        """
