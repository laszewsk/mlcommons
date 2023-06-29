SHELL=/bin/bash

INTERVAL=1.0
PROJECT=`pwd`
DATA=/scratch2/data/cloudmask/data/
UID=`id -u`
GUID=`id -g`

SDEF=singularity.def
SIF=cloudmask.sif

SDEF=tf.def
SDEF=singularity.def
SIF=tf.sif

LOCAL_BIN=/home/${USER}/.local/bin
PYTHON=~/ENV3/bin/activate

default: help

#.PHONY: help
#help: # Show help for each of the Makefile recipes.
#	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done


all: setup project # stup all

docker-image: # create a docker image
	time docker build -t cloudmask .
	docker image ls cloudmask

docker-shell: # docker image shell
	docker run --gpus all -it --rm \
    	-v /etc/passwd:/etc/passwd:ro \
    	-v /etc/group:/etc/group:ro \
	    --user ${UID}:${GID} \
	    --shm-size=1g --ulimit memlock=-1 \
	    -v ${PROJECT}:/project \
	    -v ${DATA}:/data \
	    -v ${HOME}:${HOME} \
		cloudmask


docker-run: # docker image run
	mkdir -p outputs
	time docker run --gpus all --rm \
    	-v /etc/passwd:/etc/passwd:ro \
    	-v /etc/group:/etc/group:ro \
	    --user ${UID}:${GID} \
	    --shm-size=1g --ulimit memlock=-1 \
	    -v ${PROJECT}:/project \
	    -v ${DATA}:/data \
	    -v ${HOME}:${HOME} \
		cloudmask \
		python slstr_cloud.py > ./outputs/run.log 2>&1

docker-watch: # watch the output of the current run
	tail -f ./outputs/run.log

singularity-watch: # watch the output of the current run
	tail -f ./outputs/run.log

docker-kill: # docker kill
	docker kill `docker ps -q`

singularity-run: # singularity run
	mkdir -p outputs
	time singularity exec --nv --bind ${PROJECT}:/project,${DATA}:/data,${HOME}:${HOME} tf.sif /TF/bin/python slstr_cloud.py > ./outputs/run.log 2>&1

singularity-image: # singularity image
	rm -f cloudmask.sif
	time sudo singularity build --force ${SIF} ${SDEF}
	ls -h ${SIF}

rivana-image: # rivanna singularity image
	cp ${SDEF} build.def
	date
	sudo /opt/singularity/3.7.1/bin/singularity build output_image.sif build.def
	date
	cp output_image.sif ${SIF}
	rm -f build.def output_image.sif

singularity-shell: # singularity shell
	sudo singularity shell --bind ${PROJECT}:/project,${DATA}:/data,${HOME}:${HOME} ${SIF}

singularity-clean: # singularity clean
	sudo singularity cache clean -f
	rm -f cloudmask.sif

project: project.json generate # project

setup: # setup
	source ~/ENV3/bin/activate && pip install -r /$(WORKDIR)/$(USER)/mlcommons/benchmarks/cloudmask/experiments/ubuntu-sh/requirements.txt

generate: jobs-project.sh # generate

# run: submit

submit: # submit
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

data: # data
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

stop: #stop
	for i in "$$(squeue --user $$USER | awk 'NR>1{print $$1}')"; do scancel $$i ; done

inspect: #inspect
	$(eval D=$(shell ls project/$(ls -1) | head -n 1))
	echo ${D}
	$(shell emacs project/${D}/config.yaml project/${D}/job.sh)

watch: status # watch

status: #status
	watch squeue --format=\"%.18i %.9P %.50j %.8u %.8T %.10M %.9l %.6D %R\" --me


clean: # clean
	@-rm -rf project project.json jobs-project.sh
	@-rm -f job.sh
	@-rm -rf '__pycache__'
	@-rm -rf *~
