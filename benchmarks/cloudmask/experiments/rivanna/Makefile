SHELL=/bin/bash

LOCAL_BIN=/home/${USER}/.local/bin
PYTHON=py3.10

.PHONY: project

all: project localscratch shm generate


setup:
	python setup_env_and_yaml.py

generate: jobs-project.sh 

generate-project: jobs-project.sh

run: submit

submit:
	-sh jobs-project.sh


project: config.yaml project.json


localscratch: localscratch.json


jobs-%.sh: %.json
	cms sbatch generate submit --name=$<  > $@

%.json: config.yaml
	cms sbatch generate \
	           --source=job.in.slurm \
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
	cd /scratch/$(USER)/mlcommons/benchmarks/cloudmask/ && \
	   mkdir -p data/ssts && mkdir -p data/one-day
	module load anaconda && source activate $(PYTHON) && pip install awscli
	echo -n "Downloading first portion of data..." ; module load anaconda && source activate $(PYTHON) && \
           cd /scratch/$(USER)/mlcommons/benchmarks/cloudmask/ && \
           $(LOCAL_BIN)/aws s3 --no-sign-request --endpoint-url https://s3.echo.stfc.ac.uk sync s3://sciml-datasets/es/cloud_slstr_ds1/one-day ./data/one-day --cli-read-timeout 0
	echo -n "Downloading second portion of data..." ; module load anaconda && source activate $(PYTHON) && \
            cd /scratch/$(USER)/mlcommons/benchmarks/cloudmask/ && \
            $(LOCAL_BIN)/aws s3 --no-sign-request --endpoint-url https://s3.echo.stfc.ac.uk sync s3://sciml-datasets/es/cloud_slstr_ds1/ssts ./data/ssts --cli-read-timeout 0

stop:
	for i in "$$(squeue --user $$USER | awk 'NR>1{print $$1}')"; do scancel $$i ; done

inspect:
	$(eval D=$(shell ls project/$(ls -1) | head -n 1))
	echo ${D}
	$(shell emacs project/${D}/config.yaml project/${D}/job.slurm)

clean:
	@-rm -rf localscratch localscratch.json jobs-localscratch.sh
	@-rm -rf project project.json jobs-project.sh
	@-rm -f rivanna.slurm
	@-rm -rf '__pycache__'
