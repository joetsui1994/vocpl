#!/usr/bin/env nextflow

// DSL 2
nextflow.enable.dsl=2

// run TreeTime mugration
process treetime_dta {
    publishDir "${params.out_dir}/s${key}/DTA", mode: "copy"
    input:
        tuple val(key), path(ml_treetime_final_nwk)
    output:
        file "*"
        tuple val(key), path("annotated_tree.nexus"), emit: treetime_dta
    when:
        params.treetime_init.stop != true

    """
    treetime mugration \
        --tree $ml_treetime_final_nwk \
        --states $params.master_metadata \
        --attribute country \
        --outdir ./
    """
}

// extract state changes from TreeTime mugration output
process extract_states {
    publishDir "${params.out_dir}/s${key}/DTA", mode: "copy"
    input:
        tuple val(key), path(annotated_tree_nex)
    output:
        file "*"
        
    """
    gotree labels -i $annotated_tree_nex --format nexus --tips > final_tips.tsv
    awk -F '\t' -v OFS='\t' 'NR==FNR { a[\$1]; next } FNR==1 || \$1 in a { print \$0 }' final_tips.tsv $params.master_metadata > final_metadata.tsv
    last_sample=\$(python3 $projectDir/lib/scripts/sort_dates.py \
        --infile final_metadata.tsv \
        --outfile final_metadata.sorted.tsv \
        --latest)
    python3.7 $projectDir/lib/scripts/extract_dta.py \
        --infile $annotated_tree_nex \
        --outfile state_changes.tsv \
        --time \$last_sample
    """
}

workflow dta {
    take:
        ch_tree_metadata
    main:
        ch_tree_metadata \
            | treetime_dta

        treetime_dta.out.treetime_dta \
            | extract_states
}