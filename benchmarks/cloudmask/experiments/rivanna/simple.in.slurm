#!/bin/bash

#SBATCH --job-name=cloudmask-gpu-greene
#SBATCH --nodes=1
#SBATCH --gres=gpu:v100:1
#SBATCH --time=02:00:00
#SBATCH --mem=64G
#SBATCH -o outputs/%j.out
#SBATCH -e outputs/%j.err
#SBATCH --partition=bii-gpu
#SBATCH --account=bii_dsc_community

export USER_SCRATCH=/scratch/$USER
export PROJECT_DIR=$USER_SCRATCH/mlcommons/benchmarks/cloudmask
export PYTHON_DIR=$USER_SCRATCH/ENV3
export PROJECT_DATA=$USER_SCRATCH/data

source $PYTHON_DIR/bin/activate

which python

nvidia-smi

cd $PROJECT_DIR/experiments/rivanna

cms gpu watch --gpu=0 --delay=0.5 --dense > outputs/gpu0.log &

python slstr_cloud.py --config config.yaml

seff $SLURM_JOB_ID
