# VOC-PL
This is a NEXTFLOW implementation for the pipeline for analysing the global source-sink dynamics of VOCs.

### Setup
- build the docker image from the provided Dockerfile by running ```docker build -t docker_name .``` in the project folder
- once you have built the docker image, simply run the provided run.sh bash script file to start experimenting (you might have to make run.sh executable first by running ```chmod +x run.sh```)
- run.sh will first take the custom config file ex_config.yaml and replace any environmental variables with their corresponding values in your local environment using ```envsubst```; the newly generated config file (ex_sub_config.yaml) is then used as the params-file for running nextflow

### Configuration
