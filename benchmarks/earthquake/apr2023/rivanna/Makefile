SHELL := /bin/bash

# NOTEBOOK=FFFFWNPFEARTHQ_newTFTv29-mllog-gregor.ipynb
NOTEBOOK=FFFFWNPFEARTHQ_newTFTv29-mllog.ipynb
VENV=/scratch/$(USER)/EQ

.PHONY: clean project localscratch dgx dgx-shm shm singularity stop singularity.json

all: project localscratch shm generate

setup-%: rivanna-%.yaml
	python 01-fetch-data.py $<
	python 02-setup-venv.py $<

generate: jobs-project.sh jobs-localscratch.sh jobs-dgx.sh
#generate-%: jobs-%.sh

generate-dgx: jobs-dgx.sh
generate-localscratch: jobs-localscratch.sh
generate-shm: jobs-shm.sh
generate-dgx: jobs-dgx.sh
generate-singularity: jobs-singularity.sh

run: submit

submit: all
	sh jobs-project.sh
	sh jobs-localscratch.sh
	sh jobs-dgx.sh

project: project.json

localscratch: localscratch.json

dgx: dgx.json

dgx-shm: dgx-shm.json

shm: shm.json

singularity: singularity.json

jobs-%.sh: %.json
	source ${VENV}/bin/activate ; \
	cms sbatch generate submit --name=$<  > $@

singularity.json: config.yaml
	source ${VENV}/bin/activate ; \
	cms sbatch generate \
	           --source=slurm-a100-ipynb.sh \
	           --config=$< \
	           --name=$(basename $@) \
	           --noos \
	           --os=USER \
	           --output_dir=./$(basename $@) \
               --source_dir=. \
               --copycode=$(NOTEBOOK) \
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
               --copycode=$(NOTEBOOK) \
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
               --copycode=$(NOTEBOOK) \
               --verbose

stop:
	for i in "$$(squeue --user $$USER | awk 'NR>1{print $$1}')"; do scancel $$i ; done


clean:
	@-rm -rf localscratch localscratch.json jobs-localscratch.sh
	@-rm -rf project project.json jobs-project.sh
	@-rm -rf dgx dgx.json jobs-dgx.sh
	@-rm -rf shm shm.json jobs-shm.sh
	@-rm -f rivanna.slurm
	@-rm -rf '__pycache__'


#
# image
#

image:
	cd image-singularity; make image
	mv image-singularity/earthquake.sif .

push:
	-git push
	ssh -tt rivanna "cd /scratch/thf2bn/mlcommons/benchmarks/earthquake/apr2023/rivanna; ssh-add; git pull"