SHELL=/bin/bash
AWS_S3=aws s3 --no-sign-request --endpoint-url https://s3.echo.stfc.ac.uk
USER_SCRATCH=/scratch/${USER}
PROJECT_DIR=${USER_SCRATCH}/mlcommons/benchmarks/cloudmask
PROJECT_DATA=${USER_SCRATCH}/data

.PHONY: data clean project localscratch singularity stop singularity.json

all: requirements data

download:
	git clone git@github.com:laszewsk/mlcommons.git

requirements:
	time pip install -r ${PROJECT_DIR}/experiments/rivanna/requirements.txt

data: 
	mkdir -p ${PROJECT_DATA}/ssts
	mkdir -p ${PROJECT_DATA}/one-day
	echo -n "Downloading first portion of data..."
	cd ${PROJECT_DATA}; ${AWS_S3} sync s3://sciml-datasets/es/cloud_slstr_ds1/one-day ./one-day --cli-read-timeout 0
	echo -n "Downloading second portion of data..."
	cd ${PROJECT_DATA}; ${AWS_S3} sync s3://sciml-datasets/es/cloud_slstr_ds1/ssts ./ssts --cli-read-timeout 0


project: project.json generate

setup:
	python setup_env_and_yaml.py
	source ~/ENV3/bin/activate && pip install -r /scratch/${USER}/mlcommons/benchmarks/cloudmask/experiments/rivanna/requirements.txt

generate: jobs-project.sh 

run: submit

submit:
	-sh jobs-project.sh

localscratch: localscratch.json


jobs-%.sh: %.json
	cms sbatch generate submit --name=$<  > $@


simple:
	cms sbatch generate \
	           --source=simple.in.slurm \
	           --config=$< \
	           --name=$(basename $@) \
	           --noos \
	           --os=USER,HOME \
		   	   --nocm \
	           --output_dir=./$(basename $@) \
               --source_dir=. \
               --verbose


%.json: config.yaml
	cms sbatch generate \
	           --source=job.in.slurm \
	           --config=$< \
	           --name=$(basename $@) \
	           --noos \
	           --os=USER,HOME \
		   --nocm \
	           --output_dir=./$(basename $@) \
               --source_dir=. \
               --verbose

kill: stop

stop:
	for i in "$$(squeue --user $$USER | awk 'NR>1{print $$1}')"; do scancel $$i ; done

inspect:
	$(eval D=$(shell ls project/$(ls -1) | head -n 1))
	echo ${D}
	$(shell emacs project/${D}/config.yaml project/${D}/job.slurm)

watch: status

status:
	watch squeue --format=\"%.18i %.9P %.50j %.8u %.8T %.10M %.9l %.6D %R\" --me


clean:
	@-rm -rf localscratch localscratch.json jobs-localscratch.sh
	@-rm -rf project project.json jobs-project.sh
	@-rm -f rivanna.slurm
	@-rm -rf '__pycache__'
	@-rm -rf *~

