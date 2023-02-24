#!/bin/bash
#
#SBATCH --job-name=Cloudmask-GPU-Greene
#SBATCH --nodes=1
#SBATCH --gres=gpu:a100:1
#SBATCH --time=02:00:00
#SBATCH --mem=64G
#SBATCH -o outputs/%j.out
#SBATCH -e outputs/%j.err

export USER_SCRATCH=/scratch/$USER/github-fork
export PROJECT_DIR=$USER_SCRATCH/mlcommons/benchmarks/cloudmask
export PYTHON_DIR=/scratch/$USER/ENV3
export PROJECT_DATA=$USER_SCRATCH/data


module purge
# module load anaconda3/2020.07
module load cudnn/8.6.0.163-cuda11

# source /share/apps/anaconda3/2020.07/etc/profile.d/conda.sh
source $PYTHON_DIR/bin/activate
# export PATH=/scratch/vc2209/TestEnv/bin:$PATH

cd $PROJECT_DIR/experiments/greene

python slstr_cloud.py --config config.yaml

