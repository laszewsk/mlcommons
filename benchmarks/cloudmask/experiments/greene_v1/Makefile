SHELL := /bin/bash
AWS_S3=aws s3 --no-sign-request --endpoint-url https://s3.echo.stfc.ac.uk
NAME=cloudmask
VENV=/scratch/$(USER)/ENV3

.PHONY: data clean project localscratch singularity stop singularity.json

all: project localscratch shm generate

all: requirements data

requirements:
	pip install -r $(PROJECT_DIR)/experiments/greene/requirements.txt

yaml:
	sed -i 's/USERTOREPLACE/$(USER)/g' $(PROJECT_DIR)/experiments/greene/config.yaml


data: 
	mkdir -p $(PROJECT_DATA)/ssts
	mkdir -p $(PROJECT_DATA)/one-day
	echo -n "Downloading first portion of data..."
	cd $(PROJECT_DIR); $(AWS_S3) sync s3://sciml-datasets/es/cloud_slstr_ds1/one-day ./data/one-day --cli-read-timeout 0
	echo -n "Downloading second portion of data..."
	cd $(PROJECT_DIR); $(AWS_S3) sync s3://sciml-datasets/es/cloud_slstr_ds1/ssts ./data/ssts --cli-read-timeout 0

project: project.json generate

generate: jobs-project.sh 

run: submit

submit:
	-sh jobs-project.sh

localscratch: localscratch.json

jobs-%.sh: %.json
	cms sbatch generate submit --name=$<  > $@

%.json: config.in.yaml
	source ${VENV}/bin/activate ; \
	cms sbatch generate \
	           --source=slurm.in.sh \
	           --config=$< \
	           --name=$(basename $@) \
	           --noos \
	           --os=USER \
	           --output_dir=./$(basename $@) \
               --source_dir=. \
               --copycode=slstr_cloud.py \
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
	@-rm -f greene.slurm
	@-rm -rf '__pycache__'
	@-rm -rf *~



#
# SINGULARITY IMAGE
#

image:
	cd image-singularity; make image
	mv image-singularity/${NAME}.sif .

push:
	-git push
	ssh -tt rivanna "cd /scratch/thf2bn/mlcommons/ ssh-add; git pull"

shell:
	singularity shell --nv ${NAME}.sif
