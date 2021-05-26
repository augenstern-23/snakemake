#### run FastQC on the raw reads ####
rule fastqc:
    input:
        r1 = lambda wildcards: samples.at[wildcards.sample, 'fq1'],
        r2 = lambda wildcards: samples.at[wildcards.sample, 'fq1']
    output:
        html="results/qc/fastqc/{sample}.html",
        zip="results/qc/fastqc/{sample}_fastqc.zip"
    conda:
        "../envs/env.yaml"
    log:
        "logs/fastqc/{sample}.log"
    wrapper:
        "0.74.0/bio/fastqc"

#### trim reads with trimmomatic ####
rule trimmomatic_pe:
    input:
        r1 = lambda wildcards: samples.at[wildcards.sample, 'fq1'],
        r2 = lambda wildcards: samples.at[wildcards.sample, 'fq1']
    output:
        r1 ="results/trimmed/{sample}.1.fastq.gz",
        r2 ="results/trimmed/{sample}.2.fastq.gz",
        # reads where trimming entirely removed the mate
        r1_unpaired="results/trimmed/{sample}.1.unpaired.fastq.gz",
        r2_unpaired="results/trimmed/{sample}.2.unpaired.fastq.gz"
    conda:
        "../envs/env.yaml"
    log:
        "logs/trimmomatic/{sample}.log"
    params:
        # list of trimmers (see manual)
        trimmer=["TRAILING:3"],
        # optional parameters
        extra="",
        compression_level="-9"

    shell:
        """
        time java -jar Trimmomatic-0.39/trimmomatic-0.39.jar PE \
        {input.r1} {input.r2} {output.r1} {output.r1_unpaired} {output.r2} {output.r2_unpaired} ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:keepBothReads LEADING:3 TRAILING:3 MINLEN:36
        """

#### run FastQC again on filtered reads ####
rule fastqc_trimmed:
    input:
        r1 ="results/trimmed/{sample}.1.fastq.gz",
        r2 ="results/trimmed/{sample}.2.fastq.gz",
    output:
        html="results/qc/fastqc/{sample}_trimmed.html",
        zip="results/qc/fastqc/{sample}_trimmed_fastqc.zip"
    conda:
        "../envs/env.yaml"
    log:
        "logs/fastqc/{sample}_trimmed.log"
    wrapper:
        "0.74.0/bio/fastqc"

#### get mapping stastistics ####
rule qualimap2:
    input:
        "results/bam_sorted/{sample}.bam"
    output:
        directory("results/qc/qualimap_{sample}")
    conda:
        "../envs/env.yaml"
    shell:
        "qualimap_v2.2.1/qualimap bamqc -bam {input} -outdir {output} -outformat pdf -ip"

#### aggregate all quality metrics with MultiQC ####
rule multiqc:
    input:
        r1 = expand("results/qc/fastqc/{sample}.html", sample=list(samples.index)),
        r2 = expand("results/qc/fastqc/{sample}_trimmed.html", sample=list(samples.index))
    output:
        "results/qc/{sample}_multiqc.html"
    conda:
        "../envs/env.yaml"
    log:
        "logs/{sample}_multiqc.log"
    wrapper:
        "0.64.0/bio/multiqc"
