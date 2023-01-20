#!/usr/bin/env nextflow

// DSL 2
nextflow.enable.dsl=2

// add specified outgroup to alignment
process add_outgroup {
    input:
        tuple val(key), path(msa_fasta)
    output:
        tuple val(key), path("aligned.outgroup_added.fasta")
    when:
        params.nextalign.stop != true

    """
    cat $params.ml_tree.outgroup_fasta $msa_fasta > aligned.outgroup_added.fasta
    """
}

// run fasttree
process fasttree {
    publishDir "${params.out_dir}/s${key}/FastTree", mode: "copy"
    input:
        tuple val(key), path(msa_fasta)
    output:
        file "*"
        tuple val(key), path(msa_fasta), path("ml_tree.treefile"), emit: ml_tree
    
    """
    FastTree -nt \
        \$(if [ $params.ml_tree.fasttree.gtr == true ]; then echo "-gtr"; else echo ""; fi) \
        -boot $params.ml_tree.fasttree.boot \
        $params.ml_tree.fasttree.flags \
        $msa_fasta > ml_tree.treefile
    """
}

// run iqtree2
process iqtree2 {
    label "iqtree2"
    publishDir "${params.out_dir}/s${key}/IQ-TREE2", mode: "copy"
    input:
        tuple val(key), path(msa_fasta)
    output:
        file "*"
        tuple val(key), path(msa_fasta), path("ml_tree.treefile"), emit: ml_tree
    
    """
    iqtree2 -s $msa_fasta \
        -nt $params.ml_tree.iqtree.nt \
        -m $params.ml_tree.iqtree.m \
        -ninit $params.ml_tree.iqtree.ninit \
        -me $params.ml_tree.iqtree.me \
        \$(if [ $params.ml_tree.iqtree.b -gt 0 ]; then echo "-b \${params.ml_tree.iqtree.b}"; else echo ""; fi) \
        --prefix ml_tree
    """
}

workflow ml_tree {
    take:
        ch_msa
    main:
        add_outgroup(ch_msa)
        if (params.ml_tree.method.toLowerCase() == "fasttree") {
            ml_tree = add_outgroup.out | fasttree
        } else {
            ml_tree = add_outgroup.out | iqtree2
        }
    emit:
        ml_tree.ml_tree
}