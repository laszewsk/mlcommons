SHELL=/bin/bash

INTERVAL=1.0
PROJECT=`pwd`
DATA=/scratch2/data/cloudmask/data/
UID=`id -u`
GUID=`id -g`

LOCAL_BIN=/home/${USER}/.local/bin
PYTHON=~/ENV3/bin/activate

SDEF=singularity.def
SIF=cloudmask.sif


PROJECT=.

default: help

.PHONY: help
help: # Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done


all: setup project

dimage: # create a docker image
	time docker build -t cloudmask .
	docker image ls cloudmask

dshell:
	docker run --gpus all -it --rm \
    	-v /etc/passwd:/etc/passwd:ro \
    	-v /etc/group:/etc/group:ro \
	    --user ${UID}:${GID} \
	    --shm-size=1g --ulimit memlock=-1 \
	    -v ${PROJECT}:/project \
	    -v ${DATA}:/data \
	    -v ${HOME}:${HOME} \
		cloudmask


drun:
	mkdir -p outputs
	docker run --gpus all --rm \
    	-v /etc/passwd:/etc/passwd:ro \
    	-v /etc/group:/etc/group:ro \
	    --user ${UID}:${GID} \
	    --shm-size=1g --ulimit memlock=-1 \
	    -v ${PROJECT}:/project \
	    -v ${DATA}:/data \
	    -v ${HOME}:${HOME} \
		cloudmask \
		python slstr_cloud.py > ./outputs/run.log 2>&1

dkill:
	docker kill `docker ps -q`


simage:
	rm -f cloudmask.sif
	time sudo singularity build ${SIF} ${SDEF}
	ls -h ${SIF}


rimage:
	cp ${SDEF} build.def
	time sudo /opt/singularity/3.7.1/bin/singularity build output_image.sif build.def
	cp output_image.sif ${SIF}
	make -f clean

sshell:
	singularity shell cloudmask.sif

sclean:
	sudo singularity cache clean -f
	rm -f cloudmask.sif

project: project.json generate

setup:
	source ~/ENV3/bin/activate && pip install -r /$(WORKDIR)/$(USER)/mlcommons/benchmarks/cloudmask/experiments/ubuntu-sh/requirements.txt

generate: jobs-project.sh

# run: submit

submit:
	-sh jobs-project.sh

jobs-%.sh: %.json
	cms sbatch generate submit --job_type=sh --name=$<  > $@

%.json: config.yaml
	cms sbatch generate \
	           --source=job.in.sh \
	           --config=$< \
	           --name=$(basename $@) \
	           --noos \
	           --nocm \
	           --os=USER \
	           --output_dir=./$(basename $@) \
               --source_dir=. \
               --verbose

data:
	echo $(LOCAL_BIN)
	cd /$(WORKDIR)/$(USER)/mlcommons/benchmarks/cloudmask/ && \
		mkdir -p data/ssts && mkdir -p data/one-day
	source $(PYTHON) && pip install awscli
	echo -n "Downloading first portion of data..." ; source $(PYTHON) && \
    	cd /$(WORKDIR)/$(USER)/mlcommons/benchmarks/cloudmask/ && \
    	aws s3 --no-sign-request --endpoint-url https://s3.echo.stfc.ac.uk sync s3://sciml-datasets/es/cloud_slstr_ds1/one-day ./data/one-day --cli-read-timeout 0
	echo -n "Downloading second portion of data..." ; source $(PYTHON) && \
    	cd /$(WORKDIR)/$(USER)/mlcommons/benchmarks/cloudmask/ && \
    	aws s3 --no-sign-request --endpoint-url https://s3.echo.stfc.ac.uk sync s3://sciml-datasets/es/cloud_slstr_ds1/ssts ./data/ssts --cli-read-timeout 0

# kill: stop

stop:
	for i in "$$(squeue --user $$USER | awk 'NR>1{print $$1}')"; do scancel $$i ; done

inspect:
	$(eval D=$(shell ls project/$(ls -1) | head -n 1))
	echo ${D}
	$(shell emacs project/${D}/config.yaml project/${D}/job.sh)

watch: status

status:
	watch squeue --format=\"%.18i %.9P %.50j %.8u %.8T %.10M %.9l %.6D %R\" --me


clean:
	@-rm -rf project project.json jobs-project.sh
	@-rm -f job.sh
	@-rm -rf '__pycache__'
	@-rm -rf *~
