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


rule hamronize:
    input:
        amrfinder_output="data/amrfinder/{sample}.txt",
        database_version="data/amrfinder_database_version.txt",
        amrfinder_version="data/amrfinder_version.txt"
    output:
        "data/hamronize/{sample}.txt",
    conda:
        "../envs/hamronization.yml"
    threads: 1
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 1000,
        time=lambda wildcards, attempt: attempt * 10,
    shell:
        """
        software_version=$(cat {input.amrfinder_version})
        db_version=$(cut -f3 -d" " {input.database_version} | tail -n 1)
        hamronize amrfinderplus --input_file_name {input.amrfinder_output} --reference_database_version "$db_version" --analysis_software_version "$software_version" --format tsv --output {output} {input.amrfinder_output}
        """


rule hamronize_summary:
    input:
        expand("data/hamronize/{sample}.txt", sample=samples["sample"]),
    output:
        "data/hamronize_summary.tsv",
    conda:
        "../envs/hamronization.yml"
    threads: 1
    resources:
        mem_mb=lambda wildcards, attempt: attempt * 5000,
        time=lambda wildcards, attempt: attempt * 10,
    shell:
        """
        hamronize summarize -t tsv -o {output} {input}
        """
