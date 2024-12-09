rule gubbins:
    input:
        "data/alignments/core.full.aln"
    output:
        "data/trees/gubbins/core.final_tree.tre"
    conda:
        "../envs/gubbins.yml"
    threads: 8
    resources:
        mem=16000,
        runtime=30
    shell:
        """
        run_gubbins.py --threads {threads} --prefix data/trees/gubbins/core {input}
        """
