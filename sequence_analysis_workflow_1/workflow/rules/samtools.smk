rule samtools_sort:
    input:
        "results/mapped/{file}.bam"
    output:
        "results/bam_sorted/{file}.bam"
    conda:
        "../envs/env.yaml"
    threads: 4
    shell:
        "samtools sort -@ threads -T sorted_reads/{wildcards.file} "
        "-O bam {input} > {output}"

rule samtools_index:
    input:
        "results/bam_sorted/{file}.bam"
    output:
        "results/bam_sorted/{file}.bam.bai"
    conda:
        "../envs/env.yaml"
    threads: 4
    shell:
        "samtools index -@ threads {input}"

rule samtools_stats:
    input:
        bam = "results/bam_sorted/{file}.bam",
        idx = "results/bam_sorted/{file}.bam.bai"
    output:
        "results/stats/{file}.bam.idxstats"
    conda:
        "../envs/env.yaml"
    threads: 4
    log:
        "results/logs/samtools/idxstats/{file}.log"
    wrapper:
        "0.74.0/bio/samtools/idxstats"
