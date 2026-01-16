rule seqsero2:
    input:
        fasta="data/filtered_assemblies/{sample}_contigs_filtered.fa",
    output:
        "data/seqsero2/{sample}/SeqSero_result.tsv"
    conda:
        "../envs/seqsero2.yml"
    threads: 1
    resources:
        mem_mb=8000,
        runtime=10
    shell:
        """
        mkdir -p data/seqsero2
        SeqSero2_package.py -i {input.fasta} -n {wildcards.sample} -p {threads} -t 4 -m k -d data/seqsero2/{wildcards.sample}
        """
