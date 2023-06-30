NAME=cloudmask
TAG=cloudmask:latest

image:
	cp ../requirements.txt .
	time docker build -t ${TAG} .

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

# TODO
run:
	singularity exec --nv ${NAME}.sif papermill ${NAME}.ipynb ${NAME}_output.ipynb

shell:
	docker run --gpus all --ipc=host --ulimit memlock=-1  -it ${TAG} /bin/bash
	# --ulimit stack=67108864

cancel: stop

stop:
	for i in "$$(squeue --user $$USER | awk 'NR>1{print $$1}')"; do scancel $$i ; done

view:
	watch tail -n 50 *.err

all: delete clean image submit view
