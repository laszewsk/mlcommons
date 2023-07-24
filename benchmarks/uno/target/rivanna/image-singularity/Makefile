NAME=uno
VERSION=v2
PRG=uno_mllog_$(VERSION)
CODE_DIR=..
BUILD=$(NAME).def
IMAGE=$(NAME).sif
DATA=/scratch2/data/$(NAME)/data
BIND=--bind ${DATA}:${DATA}

DATA_LOCALSCRATCH=/localscratch/${USER}/$(NAME)/
BIND_LOCALSCRATCH=--bind ${DATA}:${DATA}

image:
	time ../bin/singularity-image.py ${NAME}

queue: watch

delete:
	rm -f *.out *.err
	rm -f *_output.ipynb
	rm *.log

# TODO
submit:
	sbatch simple-a100-singularity.sh

watch: status

status:
	watch squeue --format=\"%.18i %.9P %.50j %.8u %.8T %.10M %.9l %.6D %R\" --me

run:
	cd ${CODE_DIR}; mkdir -p outputs
	cd ${CODE_DIR}; singularity exec ${BIND} --nv $(NAME).sif bash -c "python $(PRG).py --config=config.yaml"

#singularity exec --nv ${NAME}.sif papermill ${NAME}.ipynb ${NAME}_output.ipynb

shell:
	singularity ${BIND} shell --nv ${IMAGE}

run-localscratch:
	cd ${CODE_DIR}; mkdir -p outputs
	cd ${CODE_DIR}; singularity exec ${BIND_LOCALSCRATCH} --nv $(NAME).sif bash -c "python $(NAME)_v2.py --config=config-new.yaml"

#singularity exec --nv ${NAME}.sif papermill ${NAME}.ipynb ${NAME}_output.ipynb

shell-localscratch:
	singularity ${BIND_LOCALSCRATCH} shell --nv ${IMAGE}

shell-rivanna:
	singularity shell --nv ${IMAGE}


cancel: stop

stop:
	for i in "$$(squeue --user $$USER | awk 'NR>1{print $$1}')"; do scancel $$i ; done

view:
	watch tail -n 50 *.err

all: delete clean image submit view
