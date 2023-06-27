#!/bin/bash
#
#SBATCH --job-name=cloudmask-gpu-greene-epoch-1
#SBATCH --nodes=1
#SBATCH --gres=gpu:v100:1
#SBATCH --time=00:40:00
#SBATCH --mem=64G
#SBATCH -o outputs/%u-%j.out
#SBATCH -e outputs/u%-%j.err

export USER_SCRATCH=/scratch/$USER/github-fork
export PROJECT_DIR=$USER_SCRATCH/mlcommons/benchmarks/cloudmask
export PYTHON_DIR=$USER_SCRATCH/ENV3
export PROJECT_DATA=$USER_SCRATCH/data
# export PROJECT_DATA=/scratch/vc2209/github-fork/data

module purge
# module load anaconda3/2020.07
module load cudnn/8.6.0.163-cuda11

# source /share/apps/anaconda3/2020.07/etc/profile.d/conda.sh
source $PYTHON_DIR/bin/activate
# export PATH=/scratch/vc2209/TestEnv/bin:$PATH

which python

nvidia-smi

cd $PROJECT_DIR/experiments/greene

cms gpu watch --gpu=0 --delay=0.5 --dense > outputs/gpu0.log &

python slstr_cloud.py --config config_simple.yaml

seff $SLURM_JOB_ID
