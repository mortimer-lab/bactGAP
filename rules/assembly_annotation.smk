rule spades:
    input:
        read1="data/trimmed/{sample}_1.fastq.gz",
        read2="data/trimmed/{sample}_2.fastq.gz",
    output:
        "data/spades/{sample}/contigs.fasta"
    conda:
        "../envs/spades.yml"
    threads: 8
    resources:
        mem_mb=lambda wildcards, attempt: 16000,
        runtime=lambda wildcards, attempt: attempt * 60
    shell:
        """
        spades.py -t {threads} -m 16 --isolate -1 {input.read1} -2 {input.read2} -o data/spades/{wildcards.sample}
        """

rule filter_assembly:
    input:
        fasta="data/spades/{sample}/contigs.fasta"
    params:
        name="{sample}"
    output:
        fasta="data/filtered_assemblies/{sample}_contigs_filtered.fa"
    run:
        shell("mkdir -p data/filtered_assemblies")
        contigs = []
        for contig in SeqIO.parse(input.fasta, "fasta"):
            contig_length = int(contig.id.split("_")[-3])
            contig_coverage = float(contig.id.split("_")[-1])
            if contig_length > 500 and contig_coverage > 10:
                contig.id = contig.id.replace("NODE", params.name)
                contigs.append(contig)
        SeqIO.write(contigs, output.fasta, "fasta")


rule bakta:
    input:
        fasta="data/filtered_assemblies/{sample}_contigs_filtered.fa",
        db="data/bakta_db/db/bakta.db"
    output:
        protein="data/annotations/{sample}/{sample}.faa",
        gff="data/annotations/{sample}/{sample}.gff3"
    params:
        genus=config["genus"],
        species=config["species"]
    conda:
        "../envs/bakta.yml"
    threads: 8
    resources:
        mem_mb=16000,
        runtime=lambda wildcards, attempt: attempt * 90
    shell:
        """
        mkdir -p data/annotations
        bakta --force --db data/bakta_db/db --prefix {wildcards.sample} --output data/annotations/{wildcards.sample} --genus {params.genus} --species {params.species} --strain {wildcards.sample} --locus-tag {wildcards.sample} --threads {threads} --skip-plot {input.fasta}
        """
