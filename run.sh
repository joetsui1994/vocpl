#!/bin/bash

envsubst < ex_config.yaml > ex_sub_config.yaml
nextflow run main.nf -params-file ex_sub_config.yaml -with-docker joetsui1994/vocpl -resume
