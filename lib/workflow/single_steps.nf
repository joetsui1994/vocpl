// run nextalign
process nextalign {
    label "nextalign"
    publishDir "${params.out_dir}/s${key}/Nextalign", mode: "copy"
    input:
        tuple val(key), path(subsample_prealign_fasta), path(nextalign_reference), path(nextalign_genemap), val(nextalign_genes)
    output:
        file "*"
        tuple val(key), path("nextalign.aligned.fasta"), emit: aligned_fasta
    when:
        params.subsampler.stop != true

    """
    nextalign run \
        --input-ref=$nextalign_reference \
        --genemap=$nextalign_genemap \
        --genes=$nextalign_genes \
        --output-all=. \
        $subsample_prealign_fasta
    """
}