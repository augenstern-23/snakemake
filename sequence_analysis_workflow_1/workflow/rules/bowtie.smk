rule bowtie2:
    input:
        r1 = lambda wildcards: samples.at[wildcards.sample, 'fq1'],
        r2 = lambda wildcards: samples.at[wildcards.sample, 'fq1']
    output:
        "results/mapped/{sample}.bam"
    conda:
        "../envs/env.yaml"
    params:
        bw_index = config["index"],
        bw_sensitive = config["params"]["bowtie2_sensitive"],
        bw_n = config["params"]["bowtie2_n"]
    threads: 4
    shell:
        "bowtie2 -p {threads} {params.bw_n} {params.bw_sensitive} -x {params.bw_index} -1 {input.r1} -2 {input.r2} -S {output}"
