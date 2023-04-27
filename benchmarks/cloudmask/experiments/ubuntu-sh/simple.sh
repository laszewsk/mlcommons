#!/bin/bash

export USER_SCRATCH=/scratch2/data/cloudmask
export PROJECT_DIR=/home/$USER/Desktop/github/mlcommons/benchmarks/cloudmask/experiments/ubuntu-sh
export PYTHON_DIR=$USER/ENV3
export PROJECT_DATA=$USER_SCRATCH/data

source $PYTHON_DIR/bin/activate

which python

nvidia-smi

cd $PROJECT_DIR/experiments/rivanna

% cms gpu watch --gpu=0 --delay=0.5 --dense > outputs/gpu0.log &

python slstr_cloud.py --config config.yaml

