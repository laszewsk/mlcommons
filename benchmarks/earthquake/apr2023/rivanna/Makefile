NAME=earthquake

BUILD=${NAME}.def
IMAGE=${NAME}.sif

image:
	cp ${BUILD} build.def
	sudo /opt/singularity/3.7.1/bin/singularity build output_image.sif build.def
	cp output_image.sif ${IMAGE}
	make -f Makefile clean

clean:
	rm -rf build.def output_image.sif

queue: watch

delete:
	rm -f *.out *.err
	rm -f *_output.ipynb
	rm *.log

submit:
	sbatch slurm-a100-ipynb.sh

watch: status

status:
	watch squeue --format=\"%.18i %.9P %.50j %.8u %.8T %.10M %.9l %.6D %R\" --me

run:
	singularity exec --nv ${NAME}.sif papermill ${NAME}.ipynb ${NAME}_output.ipynb

shell:
	singularity shell --nv ${NAME}.sif

cancel: stop

stop:
	for i in "$$(squeue --user $$USER | awk 'NR>1{print $$1}')"; do scancel $$i ; done

view:
	watch tail -n 50 *.err

all: delete clean image submit view

convert-to-ssh-repo:
	git remote set-url origin git@github.com:laszewsk/mlcommons.git
