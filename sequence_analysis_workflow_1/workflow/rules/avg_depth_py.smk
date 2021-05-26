rule avg_depth_py:
    input:
        "results/stats/{file}.bam.idxstats"
    output:
        "results/stats/{file}_avg_depth.bam.idxstats"
    script:
        "../scripts/calc_idxstats.py"
