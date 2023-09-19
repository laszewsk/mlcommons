# export $PROJECT_SOURCE=/scratch/$USER/github/mlcommons/benchmarks/cloudmask/target/greene-overlay
# export $PROJECT_DIR=/scratch/$USER/github/mlcommons/benchmarks/cloudmask/target/greene-overlay-test
# export SCRTACH=/scratch/$USER/github/

.ONESHELL:
SHELL=/bin/sh

info:
	cd $(<D)
	echo $PROJECT_SOURCE
	echo $PROJECT_DIR
	echo $SCRATCH

setup: mkdir-scratch clone
		

mkdir-scratch:
	mkdir -p $SCRATCH

clone:
	cd $SCRATCH
	git clone https://github.com/laszewsk/mlcommons.git
	cp -r $PROJECT_SOURCE $PROJECT_DIR 

image-pull: cloudmask.sif
	cd $PROJECT_DIR
	cd  singularity pull docker://nvcr.io/nvidia/tensorflow:22.10-tf2-py3
	make -f Makefile image-copy

image-copy:
	cd $PROJECT_DIR
	cp tensorflow_22.10-tf2-py3.sif cloudmask.sif

image-create: image-copy
	cd $PROJECT_DIR
	cp -rp /scratch/work/public/overlay-fs-ext3/overlay-15GB-500K.ext3.gz .
	gunzip overlay-15GB-500K.ext3.gz


image-mod:
	cd $PROJECT_DIR
	singularity exec --overlay overlay-15GB-500K.ext3:rw cloudmask.sif /bin/bash

image-script:
	cd $PROJECT_DIR
	echo <<EOF
	unset -f which
	which python
	which pip
	python --version

	pip install pip -U ; python --version
	pip install scikit-learn

	# pip install aws-cli

	# install from requirements file in rivanna folder
	# pip install protobuf==3.20.0 numpy tensorflow

	pip install h5py
	pip install pyyaml
	pip install git+https://github.com/mlperf/logging.git@1.0.0

	pip install cloudmesh-common
	pip install cloudmesh-gpu
	pip install cloudmesh-sbatch

	EOF > a.sh



