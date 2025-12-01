rule snippy:
    input:
        read1="data/trimmed/{sample}_1.fastq.gz",
        read2="data/trimmed/{sample}_2.fastq.gz",
        reference="data/reference/reference.fasta"
    output:
        "data/snippy/{sample}/snps.vcf"
    conda:
        "../envs/snippy.yml"
    threads: 8
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 8000,
        runtime=lambda wildcards, attempt: attempt * 15
    params:
        ram=lambda wildcards, resources: resources.mem_mb//1000
    shell:
        """
        snippy --force --cpus {threads} --ram {params.ram} --mincov 20 --minfrac 0.9 --outdir data/snippy/{wildcards.sample} --ref {input.reference} --R1 {input.read1} --R2 {input.read2} 
        """

rule snippy_core:
    input:
        reference="data/reference/reference.fasta",
        vcfs=expand("data/snippy/{sample}/snps.vcf", sample=samples["sample"])
    output:
        "data/alignments/core.full.aln"
    conda:
        "../envs/snippy.yml"
    shell:
        """
        snippy-core --prefix data/alignments/core --ref {input.reference} data/snippy/*
        """
