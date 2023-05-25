NAME=local/earthquake-nvidia

image:
	time docker build -t ${NAME} -f Dockerfile .

queue: watch

delete:
	rm -f *.out *.err
	rm -f *_output.ipynb
	rm *.log

# TODO
submit:
	sbatch slurm-a100-ipynb.sh

watch: status

status:
	watch squeue --format=\"%.18i %.9P %.50j %.8u %.8T %.10M %.9l %.6D %R\" --me

# TODO
run:
	# --ipc=host
	# stack=67108864
	docker run --gpus all --ulimit memlock=-1 ${NAME}  papermill earthquake.ipynb earthquake_output.ipynb

ls:
	docker images ${NAME}

shell:
	docker run -it --gpus all --ulimit memlock=-1 ${NAME}

cancel: stop

stop:
	for i in "$$(squeue --user $$USER | awk 'NR>1{print $$1}')"; do scancel $$i ; done

view:
	watch tail -n 50 *.err

all: delete clean image submit view
