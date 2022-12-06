SHELL := /bin/bash

all: project localscratch shm generate

setup:
	python setup_env_and_yaml.py

generate: jobs-project.sh jobs-localscratch.sh jobs-dgx.sh
#generate-%: jobs-%.sh

generate-dgx: jobs-dgx.sh
generate-project: jobs-project.sh
generate-shm: jobs-shm.sh
generate-dgx: jobs-dgx.sh

run: submit

submit:
	-sh jobs-project.sh
	-sh jobs-localscratch.sh
	-sh jobs-dgx.sh



.PHONY: project
project: project.json

.PHONY: localscratch
localscratch: localscratch.json

.PHONY: dgx
dgx: dgx.json

.PHONY: dgx-shm
dgx-shm: dgx-shm.json

.PHONY: shm
shm: shm.json

jobs-%.sh: %.json
	cms sbatch generate submit --name=$<  > $@

%.json: cloudMaskConfig.yaml
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

dgx.json: rivanna-dgx.yaml
		cms sbatch generate \
	           --source=rivanna-dgx.in.slurm \
	           --config=$< \
	           --name=$(basename $@) \
	           --noos \
	           --os=USER \
	           --output_dir=./$(basename $@) \
               --source_dir=. \
               --verbose

dgx-shm.json: rivanna-dgx-shm.yaml
		cms sbatch generate \
	           --source=rivanna-dgx.in.slurm \
	           --config=$< \
	           --name=$(basename $@) \
	           --noos \
	           --os=USER \
	           --output_dir=./$(basename $@) \
               --source_dir=. \
               --verbose

data:
	cd /scratch/$(USER)/mlcommons/benchmarks/cloudmask/ && \
mkdir -p data/ssts && mkdir -p data/one-day
	module load anaconda && source activate MLBENCH && pip install awscli
	echo -n "Downloading first portion of data..." ; module load anaconda && source activate MLBENCH && \
cd /scratch/$(USER)/mlcommons/benchmarks/cloudmask/ && \
aws s3 --no-sign-request --endpoint-url https://s3.echo.stfc.ac.uk sync s3://sciml-datasets/es/cloud_slstr_ds1/one-day ./data/one-day --no-progress --cli-read-timeout 0 & process_id = $!
	wait $process_id
	echo -n "Downloading second portion of data..." ; module load anaconda && source activate MLBENCH && \
cd /scratch/$(USER)/mlcommons/benchmarks/cloudmask/ && \
aws s3 --no-sign-request --endpoint-url https://s3.echo.stfc.ac.uk sync s3://sciml-datasets/es/cloud_slstr_ds1/ssts ./data/ssts --no-progress --cli-read-timeout 0 & process_id_2 = $!
	wait $process_id_2

.PHONY: stop
stop:
	for i in "$$(squeue --user $$USER | awk 'NR>1{print $$1}')"; do scancel $$i ; done

.PHONY: clean
clean:
	@-rm -rf localscratch localscratch.json jobs-localscratch.sh
	@-rm -rf project project.json jobs-project.sh
	@-rm -rf dgx dgx.json jobs-dgx.sh
	@-rm -rf shm shm.json jobs-shm.sh
	@-rm -f rivanna.slurm
	@-rm -rf '__pycache__'
