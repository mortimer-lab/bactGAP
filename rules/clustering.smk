rule poppunk_input:
    output:
        qlist="data/poppunk_qlist.txt"
    run:
        with open(output.qlist, "w") as outfile:
            for s in samples["sample"]:
                outfile.write(f"{s}\tdata/filtered_assemblies/{s}_contigs_filtered.fa\n")

rule poppunk_assign:
    input:
        qlist="data/poppunk_qlist.txt"
    output:
        "data/poppunk/poppunk_clusters.csv"
    params:
        db=config["poppunk_db"]
    conda:
        "../envs/poppunk.yml"
    threads: 8
    resources:
        mem_mb=16000,
        runtime=30
    shell:
        """
        poppunk_assign --db {params.db} --query {input.qlist} --output data/poppunk --threads {threads}
        """
