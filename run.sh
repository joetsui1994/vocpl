#!/bin/bash

envsubst < ex_config.yaml > ex_sub_config.yaml
docker build -t vocpl .
nextflow run main.nf -params-file ex_sub_config.yaml -with-docker vocpl
