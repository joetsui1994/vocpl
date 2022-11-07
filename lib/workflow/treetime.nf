#!/usr/bin/env nextflow

// DSL 2
nextflow.enable.dsl=2

// treetime first run
process treetime_init {
    label "treetime"
    publishDir "${params.out_dir}/s${key}/TreeTime_init", mode: "copy"
    input:
        tuple val(key), path(msa_fasta), path(ml_tree_nwk)
    output:
        file "*"
        tuple val(key), path(msa_fasta), path("outliers.tsv"), path("ml_treetime.iter0.nwk"), emit: treetime_iter0

    """
    treetime \
        --aln $msa_fasta \
        --tree $ml_tree_nwk \
        --dates $params.master_metadata \
        --clock-rate $params.treetime_init.clock_rate \
        --clock-std-dev $params.treetime_init.clock_std_dev \
        \$(if [ -z $params.treetime_init.reroot ]; then echo "--reroot \${params.treetime_init.reroot}"; else echo ""; fi) \
        --outdir ./ \
        > log.txt

    awk -F '\t' '\$3=="--" { print \$1 }' dates.tsv > outliers.tsv
    gotree prune -f outliers.tsv -i $ml_tree_nwk --format newick > ml_treetime.iter0.nwk
    """
}

// treetime iterate
process treetime_iter {
    publishDir "${params.out_dir}/s${key}/TreeTime_iter", mode: "copy"
    input:
        tuple val(key), path(msa_fasta), path(outliers_iter0_tsv), path(ml_treetime_iter0_nwk)
    output:
        file "*"
        tuple val(key), path("ml_treetime.final.nwk"), emit: treetime_iter

    """
    i=0
    curr_tree="$ml_treetime_iter0_nwk"
    outliers_n=\$(wc -l $outliers_iter0_tsv | awk '{ print \$1 }')
    cat $outliers_iter0_tsv > all_outliers.tsv

    while [[ \$outliers_n -gt 0 && \$i -lt $params.treetime_iter.max_iter ]]
    do
        i=\$((i+1))
        treetime \
            --aln $msa_fasta \
            --tree \$curr_tree \
            --dates $params.master_metadata \
            --clock-rate $params.treetime_init.clock_rate \
            --clock-std-dev $params.treetime_init.clock_std_dev \
            \$(if [ -z $params.treetime_init.reroot ]; then echo "--reroot \${params.treetime_init.reroot}"; else echo ""; fi) \
            --outdir "treetime_iter\$i" \
            > "log_iter\$i.txt"
        
        awk -F '\t' '\$3=="--" { print \$1 }' "treetime_iter\$i/dates.tsv" > "outliers_iter\$i.tsv"
        cat "outliers_iter\$i.tsv" >> all_outliers.tsv
        gotree prune -f "outliers_iter\$i.tsv" -i \$curr_tree --format newick > "ml_treetime.iter\$i.nwk"

        outliers_n=\$(wc -l "outliers_iter\$i.tsv" | awk '{ print \$1 }')
        curr_tree="ml_treetime.iter\$i.nwk"
    done

    \$(if [ \$i -gt 0 ]; then mv "ml_treetime.iter\$i.nwk" ml_treetime.final.nwk; else mv $ml_treetime_iter0_nwk ml_treetime.final.nwk; fi)
    """
}

workflow time_calibrate {
    take:
        ch_ml_tree
    main:
        ch_ml_tree \
            | treetime_init

        treetime_init.out.treetime_iter0
            | treetime_iter
    emit:
        treetime_iter.out.treetime_iter
}