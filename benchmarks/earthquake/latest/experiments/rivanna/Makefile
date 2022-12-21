SHELL := /bin/bash

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

run: submit

submit: all
	sh jobs-project.sh
	sh jobs-localscratch.sh
	sh jobs-dgx.sh



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

%.json: rivanna-%.yaml
	cms sbatch generate \
	           --source=rivanna.in.slurm \
	           --config=$< \
	           --name=$(basename $@) \
	           --noos \
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

watch: status

status:
	watch squeue --format=\"%.18i %.9P %.50j %.8u %.8T %.10M %.9l %.6D %R\" --me

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
