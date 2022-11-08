FROM nextstrain/nextalign:latest as nextalign
FROM evolbioinfo/gotree:latest as gotree
FROM staphb/iqtree2:latest as iqtree2
FROM nanozoo/seqkit:latest as seqkit

# Using python3.7 image as a parent image
FROM python:3.7
# RUN apt-get update && apt-get install -y extra-runtime-dependencies && rm -rf /var/lib/apt/lists/* 
RUN git clone --depth=1 --branch v0.8.5 https://github.com/neherlab/treetime.git \
	 && cd treetime \
	 && pip3 install .
RUN python -m pip install baltic

# # Setting the working directory to /tmp
ENV PATH /usr/local/lib:$PATH

# # Copy the current directory contents into the container at /tmp
# COPY . /tmp

COPY --from=nextalign /nextalign /usr/local/lib/nextalign
COPY --from=gotree /usr/local/bin/gotree /usr/local/lib/gotree
COPY --from=iqtree2 /iqtree-2.1.2-Linux/bin/iqtree2 /usr/local/lib/iqtree2
COPY --from=seqkit /opt/conda/bin/seqkit /usr/local/lib/seqkit
