SHELL := /bin/bash
AWS_S3=aws s3 --no-sign-request --endpoint-url https://s3.echo.stfc.ac.uk
NAME=cloudmask
VENV=/scratch/$(USER)/ENV3
PRG=cloudmask_v0.5.py

.PHONY: project data clean project localscratch singularity stop singularity.json

all: project localscratch shm generate

all: requirements data

requirements:
	pip install -r requirements.txt

yaml:
	sed -i 's/USERTOREPLACE/$(USER)/g' $(PROJECT_DIR)/experiments/greene/config.yaml


data:
	mkdir -p $(PROJECT_DATA)/ssts
	mkdir -p $(PROJECT_DATA)/one-day
	echo -n "Downloading first portion of data..."
	cd $(PROJECT_DIR); $(AWS_S3) sync s3://sciml-datasets/es/cloud_slstr_ds1/one-day ./data/one-day --cli-read-timeout 0
	echo -n "Downloading second portion of data..."
	cd $(PROJECT_DIR); $(AWS_S3) sync s3://sciml-datasets/es/cloud_slstr_ds1/ssts ./data/ssts --cli-read-timeout 0


data-rivanna:
	time cp -rv /project/bii_dsc_community/mlcommons/data/cloudmask/* $(PROJECT_DATA)

project: project.json generate

cp-test-yaml:
	cp config-rivanna-test.in.yaml config.in.yaml

cp-rivanna-yaml:
	cp config-rivanna.in.yaml config.in.yaml

project-rivanna: cp-rivanna-yaml project submit status

test-rivanna: cp-test-yaml project submit status

project-greene:
	cp config-greene.in.yaml config.in.yaml
	make -f Makefile project

clean-project:
	rm -rf project
	rm -f project.json jobs-project.sh

generate: jobs-project.sh 

run: submit

submit:
	-sh jobs-project.sh

localscratch: localscratch.json

jobs-%.sh: %.json
	cms ee generate submit --job_type=sbatch --name=$<  > $@

%.json: config.in.yaml cloudmask_v0.5.in.slurm
	source ${VENV}/bin/activate ; \
	cms ee generate \
	           --source=cloudmask_v0.5.in.slurm \
	           --config=$< \
	           --name=$(basename $@) \
	           --noos \
	           --os=USER,HOME \
	           --output_dir=./$(basename $@) \
               --source_dir=. \
               --copycode="${PRG},data_loader.py,model.py" \
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
	watch -n 5 squeue --format=\"%.18i %.9P %.50j %.8u %.8T %.10M %.9l %.6D %R\" --me 

summary:
	watch -n 5 squeue -h -o "%.18i %.9P %.100j %.8u %.2t" --me | awk '{print $5}' | sort | uniq -c


realclean:
	@-rm -rf localscratch localscratch.json jobs-localscratch.sh
	@-rm -rf project project.json jobs-project.sh
	@-rm -f greene.slurm
	@-rm -rf '__pycache__'
	@-rm -rf *~

#
# sync and backup
#

sync:
	python ./bin/sync_project.py

tar:
	 tar cvfz project.tar.gz project

tar-gu:
	tar -czvf gu.tar.gz --include='*.log' --include='*.err' .

install-local:
	pip install pip -U
	pip install cloudmesh-common -U
	pip install cloudmesh-rivanna -U
	pip install cloudmesh-ee -U
	pip install jupyter -U
	pip install jupyterlab -U
	pip install numpy -U
	pip install maktplotlib -U
	pip install scikit-learn -U
	pip install h5py -U
	pip install pyyaml -U
	pip install seaborn -U
	pip install bokeh -U
	pip install humanize -U



# SINGULARITY IMAGE
#

image-rivanna:
	cms rivanna singularity build image-singularity/${NAME}.def


image-greene:
	singularity build image-singularity/${NAME}.def ${NAME}.sif

image:
	cd image-singularity; make image
	mv image-singularity/${NAME}.sif .

push:
	-git push
	ssh -tt rivanna "cd /scratch/thf2bn/mlcommons/ ssh-add; git pull"

shell:
	singularity shell --nv ${NAME}.sif
