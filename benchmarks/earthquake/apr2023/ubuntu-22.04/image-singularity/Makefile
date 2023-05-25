BUILD=earthquake.def
IMAGE=earthquake.sif

image:
	sudo singularity build ${IMAGE} ${BUILD}

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
	singularity exec --nv earthquake.sif papermill earthquake.ipynb mnist_output.ipynb

shell:
	singularity shell --nv earthquake.sif

cancel: stop

stop:
	for i in "$$(squeue --user $$USER | awk 'NR>1{print $$1}')"; do scancel $$i ; done

view:
	watch tail -n 50 *.err

all: delete clean image submit view
