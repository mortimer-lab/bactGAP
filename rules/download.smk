rule fasterq_dump:
    output:
        temp("data/fastqs/{sample}_1.fastq.gz"),
        temp("data/fastqs/{sample}_2.fastq.gz"),
    conda:
        "../envs/sratools.yml"
    resources:
        runtime=lambda wildcards, attempt: attempt * 30
    shell:
        """
        fasterq-dump -O data/fastqs/ {wildcards.sample}
        gzip data/fastqs/{wildcards.sample}_1.fastq
        gzip data/fastqs/{wildcards.sample}_2.fastq
        """

rule fastp:
    input:
        in1="data/fastqs/{sample}_1.fastq.gz",
        in2="data/fastqs/{sample}_2.fastq.gz"
    output:
        out1=temp("data/trimmed/{sample}_1.fastq.gz"),
        out2=temp("data/trimmed/{sample}_2.fastq.gz"),
        json="data/qc/fastp/{sample}.json",
        html="data/qc/fastq/{sample}.html"
    conda:
        "../envs/fastp.yml"
    resources:
        runtime=240
    threads: 4
    shell:
        """
        fastp --in1 {input.in1} --in2 {input.in2} --out1 {output.out1} --out2 {output.out2} --thread {threads} -j {output.json} -h {output.html}
        """

rule download_reference:
    output:
        "data/reference/reference.fasta"
    conda:
        "../envs/ncbi_datasets.yml"
    params:
        accession=config["reference"]
    shell:
        """
        datasets download genome accession {params.accession} --filename reference.zip 
        unzip -o -j reference.zip -d data/reference
        cp data/reference/{params.accession}*.fna data/reference/reference.fasta
        """

rule download_baktadb:
    output:
        "data/bakta_db/db/bakta.db"
    conda:
        "../envs/bakta.yml"
    resources:
        runtime=240
    shell:
        """
        bakta_db download --output data/bakta_db --type full
        """

rule download_syldb:
    output:
        "data/syl_db/gtdb-r220-c200-dbv1.syldb"
    conda:
        "../envs/sylph.yml"
    resources:
        runtime=240
    shell:
        """
        wget -P data/syl_db/ http://faust.compbio.cs.cmu.edu/sylph-stuff/gtdb-r220-c200-dbv1.syldb
        """

rule download_checkm2db:
    output:
        "data/CheckM2_database/uniref100.KO.1.dmnd"
    resources:
        runtime=60
    shell:
        """
        wget https://zenodo.org/records/14897628/files/checkm2_database.tar.gz
        tar xf checkm2_database.tar.gz
        mv CheckM2_database/ data/
        """
