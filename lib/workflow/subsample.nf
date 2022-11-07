#!/usr/bin/env nextflow

// DSL 2
nextflow.enable.dsl=2

// subsample sequences and extract corresponding id and metadata
process subsample_ids_metadata {
    publishDir "${params.out_dir}/s${key}/Data", mode: "copy"
    input:
        val(key)
    output:
        tuple val(key), path("subsample_ids.tsv"), path("subsample_metadata.tsv")
    
    """
    head -n1 $params.master_metadata > subsample_metadata.tsv
    shuf -n 200 $params.master_metadata >> subsample_metadata.tsv
    tail -n +2 subsample_metadata.tsv | cut -f1 > subsample_ids.tsv
    """
}

// subsample sequences and extract corresponding alignment
process subsample_alignment {
    publishDir "${params.out_dir}/s${key}/Data", mode: "copy"
    input:
        tuple val(key), path(subsample_ids)
    output:
        tuple val(key), path("subsample_aln.fasta")
    
    """
    seqkit grep -n -f $subsample_ids $params.master_fasta > subsample_aln.fasta
    """
}

workflow subsample {
    take:
        ch_seeds
    main:
        ch_seeds \
            | subsample_ids_metadata \
            | map { it[0..1] } \
            | subsample_alignment
    emit:
        subsample_alignment.out
}