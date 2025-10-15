rule get_amrfinder_database:
    output:
        database_version="data/amrfinder_database_version.txt",
        amrfinder_version="data/amrfinder_version.txt",
        amrfinder_organisms="data/amrfinder_organisms.txt"
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
        amrfinder --list_organisms > {output.amrfinder_organisms}
        """

def organism_flag():
    with open("data/amrfinder_organisms.txt", "r") as infile:
        for i,line in enumerate(infile):
            if i > 0:
                orgs = line.strip().split(": ")[1].split(", ")
                if config["genus_species"] in orgs:
                    return "-O " + config["genus_species"]
                elif config["genus"] in orgs:
                    return "-O " + config["genus"]
                else:
                    return ""
            
rule amrfinder:
    input:
        assembly="data/filtered_assemblies/{sample}_contigs_filtered.fa",
        database="data/amrfinder_database_version.txt"
    output:
        "data/amrfinder/{sample}.txt",
    params:
        organism=organism_flag
    conda:
        "../envs/amrfinder.yml"
    threads: 4
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 1000,
        time=lambda wildcards, attempt: attempt * 10,
    shell:
        """
        mkdir -p data/amrfinder
        amrfinder --plus --threads 4 --print_node {params.organism} --name {wildcards.sample} -n {input.assembly} > {output}
        """

