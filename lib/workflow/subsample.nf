#!/usr/bin/env nextflow

// DSL 2
nextflow.enable.dsl=2

// generate random subsamples of sequences and extract corresponding id and metadata
process random_subsample_ids_metadata {
    publishDir "${params.out_dir}/s${key}/Data", mode: "copy"
    input:
        val(key)
    output:
        file "*"
        tuple val(key), path("subsample_ids.tsv"), emit: subsampled_ids
    
    """
    head -n1 $params.master_metadata > subsample_metadata.tsv
    shuf -n $params.n_random $params.master_metadata >> subsample_metadata.tsv
    tail -n +2 subsample_metadata.tsv | cut -f1 > subsample_ids.tsv
    """
}

// subsample sequences and extract corresponding id and metadata
process subsample_ids_metadata {
    publishDir "${params.out_dir}/s${key}/Data", mode: "copy"
    input:
        val(key)
    output:
        file "*"
        tuple val(key), path("output_sequence_ids.txt"), emit: subsampled_ids
    
    """
    python3.7 $projectDir/lib/scripts/subsampler_timeseries.py \
        --metadata $params.master_metadata \
        --genome-matrix $params.subsampler.genome_matrix \
        --max-missing $params.subsampler.max_missing \
        --refgenome-size $params.subsampler.refgenome_size \
        --keep $params.subsampler.keep_file \
        --remove $params.subsampler.remove_file \
        --filter-file $params.subsampler.filter_file \
        --index-column $params.subsampler.id_column \
        --geo-column $params.subsampler.geo_column \
        --date-column $params.subsampler.date_column \
        --time-unit $params.subsampler.unit \
        --weekasdate no \
        --seed $key \
        --start-date $params.subsampler.start_date \
        --end-date $params.subsampler.end_date \
        --sampled-sequences "output_sequence_ids.txt" \
        --sampled-metadata "output_metadata.txt" \
        --report "output_report.txt"
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
        if (params.seeds_file?.trim()) {
            subsample_ids = ch_seeds | subsample_ids_metadata
        } else {
            subsample_ids = ch_seeds | random_subsample_ids_metadata
        }
        subsample_ids.subsampled_ids | subsample_alignment
    emit:
        subsample_alignment.out
}