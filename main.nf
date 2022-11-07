#!/usr/bin/env nextflow
/*
============================================================================================
                                    Global-VOCs Pipeline
============================================================================================
*/

// DSL 2
nextflow.enable.dsl=2
version = '1.1'

// include helper functions
// include { help_or_version; merge_params } from './lib/utilities'
include { help_or_version; read_seeds; make_seeds } from './lib/utilities'

// include workflows
include { subsample } from './lib/workflow/subsample'
include { ml_tree } from './lib/workflow/ml_tree'
include { time_calibrate } from './lib/workflow/treetime'
include { dta } from './lib/workflow/dta'

// include single-step processes
include { nextalign } from './lib/workflow/single_steps'

// help and version messages
if (params.version) {
    help_or_version(version)
}

// read seeds if provided, otherwise generate new seeds
seeds = [];
if (params.seeds_file) {
    seeds = read_seeds(params.seeds_file)
} else {
    seeds = make_seeds(Math.max(params.n_iter, 1))
}

// main workflow
workflow {

    ch_nextalign = Channel
        .of([ \
            params.nextalign.reference, \
            params.nextalign.genemap, \
            params.nextalign.genes])

    Channel
        .from(seeds) \
        | subsample \
        | combine(ch_nextalign) \
        | nextalign \

    nextalign.out.aligned_fasta \
        | ml_tree \
        | time_calibrate \
        | dta
}