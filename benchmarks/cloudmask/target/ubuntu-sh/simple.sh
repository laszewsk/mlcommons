#!/bin/bash

export USER_SCRATCH=/scratch2/data/cloudmask
export PROJECT_DIR=.
export PYTHON_DIR=$USER/ENV3
export PROJECT_DATA=$USER_SCRATCH/data

source $PYTHON_DIR/bin/activate

which python

nvidia-smi

cd $PROJECT_DIR

# cms gpu watch --gpu=0 --delay=0.5 --dense > outputs/gpu0.log &

time python slstr_cloud.py --config simple.yaml

