# VOC-PL
This is a NEXTFLOW implementation for the pipeline for analysing the global source-sink dynamics of VOCs.

### Setup
- ensure [`docker`](https://www.docker.com/) is installed and running on your system
- run the provided `run.sh` bash script file (you might have to make `run.sh` executable first by running ```chmod +x run.sh```)

`run.sh` will first take the custom config file ex_config.yaml and replace any environmental variables with their corresponding values in your local environment using ```envsubst```; the newly generated config file (ex_sub_config.yaml) is then used as the params-file for running nextflow

### Configuration
#### Global parameters
- <strong>version:</strong> If True, show version message and exit
- <strong>out_dir:</strong> Directory where output is to be written to
- <strong>master_fasta:</strong> FASTA file containing all available genomic samples
- <strong>master_metadata:</strong> CSV file (with header) containing metadata associated with genomic samples master_fasta (with same name)
- <strong>n_iter:</strong> Number of seeds to be generated (only applicable for test runs)
- <strong>n_random:</strong> Number of sequences to be sampled from file specified by master_fasta for each test run (only applicable for test runs)
- <strong>seeds_file:</strong> TXT file containing pre-specified seeds (without header)

#### Subsampler parameters
- <strong>stop:</strong> If True, execute pipeline up to and including subsampling and exit
- <strong>genome_matrix:</strong> TSV file containing corrected genome counts per unit time
- <strong>keep_file:</strong> TSV file containing name of samples to be kept in all instances
- <strong>remove_file:</strong> TSV file containing name of samples to be removed in all instances
- <strong>filter_file:</strong> TSV file containing name of samples to be batch included/excluded
- <strong>id_column:</strong> Metadata column with unique genome identifiers (genome names, accession, etc)
- <strong>geo_column:</strong> Metadata column with target geographic information (country, division, etc)
- <strong>date_column:</strong> Metadata column with collection dates
- <strong>refgenome_size:</strong> Length of genomic samples to be analysed
- <strong>max_missing:</strong> Maximum percentage of Ns or gaps allowed (integer = 1-100)
- <strong>start_date:</strong> Start date in YYYY-MM-DD format
- <strong>end_date:</strong> End date in YYYY-MM-DD format
- <strong>unit:</strong> Time unit for conversion

#### Nextalign parameters
- <strong>stop:</strong> If True, execute pipeline up to and including Nexalign and exit
- <strong>reference:</strong> FASTA file containing reference genome
- <strong>genemap:</strong> GFF file containing a table that describes the genes of the virus (name, frame, position, etc)
- <strong>genes:</strong> A string listing the genes to be considered

#### Maximum-likelihood tree-estimation parameters
- <strong>stop:</strong> If True, execute pipeline up to and including maximum-likelihood tree-estimation and exit
- <strong>method:</strong> Programme to be used (iqtree OR fasttree)
- <strong>outgroup_fasta:</strong> FASTA file containing genome sample to be used as outgroup
##### FastTree
- <strong>gtr:</strong> If True, use the Generalised Time-Reversible substitution model
- <strong>boot:</strong> Number of bootstrap replicates
- <strong>flags:</strong> A string specifying options available from FastTree (as would be entered in command line)
##### IQ-Tree
- <strong>nt:</strong> Number of CPU cores for the multicore version (AUTO will tell IQ-Tree to automatically determine the best number of cores given the current data and computer)
- <strong>m:</strong> Substitution model to be used
- <strong>ninit:</strong> Number of initial parsimony trees to be used
- <strong>me:</strong> Log-likelihood epsilon for final model parameter estimation
- <strong>b:</strong> Number of bootstrap replicates
- <strong>flags:</strong> A string specifying options available from IQ-Tree (as would be entered in command line)

#### TreeTime parameters
##### Initial run
- <strong>stop:</strong> If True, execute pipeline up to and including TreeTime and exit
- <strong>clock_rate:</strong> Assumed of molecular clock
- <strong>clock_std_dev:</strong> Standard deviation of provided clock rate estimate
- <strong>reroot:</strong> Method with which the tree is rerooted according to root-to-tip regression (min_dev, least-squares OR oldest)
##### Iterative runs
- <strong>max_iter:</strong> Maximum number of iterations of TreeTime to be performed
- <strong>max_outliers:</strong> Maximum number of outliers to be removed


