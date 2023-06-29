SHELL=/bin/bash
WORKDIR=/project1
LOCAL_BIN=/home/${USER}/.local/bin
PYTHON=~/ENV3/bin/activate

all: setup project

project: project.json generate

setup:
	source ~/ENV3/bin/activate && pip install -r /$(WORKDIR)/$(USER)/mlcommons/benchmarks/cloudmask/experiments/ubuntu-slurm/requirements.txt

generate: jobs-project.sh

run: submit

submit:
	-sh jobs-project.sh


jobs-%.sh: %.json
	cms sbatch generate submit --job_type=slurm --name=$<  > $@

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
	cd /$(WORKDIR)/$(USER)/mlcommons/benchmarks/cloudmask/ && \
		mkdir -p data/ssts && mkdir -p data/one-day
	source $(PYTHON) && pip install awscli
	echo -n "Downloading first portion of data..." ; source $(PYTHON) && \
    	cd /$(WORKDIR)/$(USER)/mlcommons/benchmarks/cloudmask/ && \
    	aws s3 --no-sign-request --endpoint-url https://s3.echo.stfc.ac.uk sync s3://sciml-datasets/es/cloud_slstr_ds1/one-day ./data/one-day --cli-read-timeout 0
	echo -n "Downloading second portion of data..." ; source $(PYTHON) && \
    	cd /$(WORKDIR)/$(USER)/mlcommons/benchmarks/cloudmask/ && \
    	aws s3 --no-sign-request --endpoint-url https://s3.echo.stfc.ac.uk sync s3://sciml-datasets/es/cloud_slstr_ds1/ssts ./data/ssts --cli-read-timeout 0

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
	@-rm -rf project project.json jobs-project.sh
	@-rm -f job.sh
	@-rm -rf '__pycache__'
	@-rm -rf *~
