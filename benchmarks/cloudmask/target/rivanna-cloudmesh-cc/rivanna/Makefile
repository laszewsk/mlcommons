SHELL:=/bin/bash

venv:
	-cd /scratch/$(USER) && git clone https://github.com/laszewsk/mlcommons.git
	cd /scratch/$(USER)/mlcommons && git pull
	cd /scratch/$(USER)/mlcommons/benchmarks/cloudmask/ && \
module load anaconda && python create_python.py
	source activate MLBENCH

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

run:
	module load anaconda && source activate MLBENCH && \
python cloudmask_runner.py

all: venv data run