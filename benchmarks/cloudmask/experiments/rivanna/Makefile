SHELL := /bin/bash

# all: project localscratch 

all: cloudmask

.PHONY: cloudmask

cloudmask: cloudMaskConfig.yaml
	cms sbatch generate \
	           --source=rivanna.in.slurm \
	           --config=$< \
	           --name=$(basename $@) \
	           --noos \
	           --os=USER \
	           --output_dir=./$(basename $@) \
               --source_dir=. \
               --verbose
	cms sbatch generate submit --name=$(basename $@)  > cloudmask.sh


setup-%: rivanna-%.yaml
	python 01-fetch-data.py $<
	python 02-setup-venv.py $<

run: submit

submit: all
	sh jobs-localscratch.sh


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
