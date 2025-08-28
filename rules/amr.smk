rule get_amrfinder_database:
    output:
        database_version="data/amrfinder_database_version.txt",
        amrfinder_version="data/amrfinder_version.txt"
    conda:
        "../envs/amrfinder.yml"
    threads: 4
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 1000,
        time=lambda wildcards, attempt: attempt * 10,
    shell:
        """
        amrfinder --update
        amrfinder --version > {output.amrfinder_version}
        amrfinder --database_version > {output.database_version}
        """

rule amrfinder:
    input:
        assembly="data/filtered_assemblies/{sample}_contigs_filtered.fa",
        database="data/amrfinder_database_version.txt"
    output:
        "data/amrfinder/{sample}.txt",
    params:
        organism=config["genus_species"]
    conda:
        "../envs/amrfinder.yml"
    threads: 4
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 1000,
        time=lambda wildcards, attempt: attempt * 10,
    shell:
        """
        mkdir -p data/amrfinder
        amrfinder --plus --threads 4 --print_node -O {params.organism} --name {wildcards.sample} -n {input.assembly} > {output}
        """

