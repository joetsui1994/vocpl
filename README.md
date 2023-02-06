# VOC-PL
This is a NEXTFLOW implementation for the pipeline for analysing the global source-sink dynamics of VOCs.

### Setup
- build the docker image from the provided Dockerfile by running ```docker build -t docker_name .``` in the project folder
- once you have built the docker image, simply run the provided run.sh bash script file to start experimenting (you might have to make run.sh executable first by running ```chmod +x run.sh```)
- run.sh will first take the custom config file ex_config.yaml and replace any environmental variables with their corresponding values in your local environment using ```envsubst```; the newly generated config file (ex_sub_config.yaml) is then used as the params-file for running nextflow

### Configuration
## Global Paramters
- <strong>version:</strong> If True, show version message and exit
- <strong>out_dir:</strong> Path of directory where all output is to be written to
- <strong>master_fasta:</strong> Path of fasta file containing all available genomic samples
- <strong>master_metadata:</strong> Path of csv file containing metadata associated with genomic samples in file specified by master_fasta
- <strong>n_iter:</strong> Number of seeds to be generated (only applicable for test runs)
- <strong>n_random:</strong> Number of sequences to be sampled from file specified by master_fasta for each test run (only applicable for test runs)
- <strong>seeds_file:</strong> Path of text file containing pre-specified seeds (without header)