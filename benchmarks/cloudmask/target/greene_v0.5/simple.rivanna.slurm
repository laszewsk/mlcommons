#!/bin/bash
#

#SBATCH --job-name=simple-cloudmask-gpu-rivanna
#SBATCH --nodes=1
#SBATCH --gres=gpu:v100:1
#SBATCH --time=06:00:00
#SBATCH --mem=64G
#SBATCH -o outputs/simple-rivanna-v100-%u-%j.out
#SBATCH -e outputs/simple-rivanna-v100-%u-%j.err
#SBATCH --partition=bii-gpu
#SBATCH --account=bii_dsc_community


export USER_SCRATCH=/scratch/$USER/github
export PROJECT_DIR=$USER_SCRATCH/mlcommons/benchmarks/cloudmask
export PYTHON_DIR=$USER_SCRATCH/ENV3
export PROJECT_DATA=/scratch/$USER/data
export TARGET=$PROJECT_DIR=/target/greene_v0.5

module purge
# module load anaconda3/2020.07
module load cudnn/8.6.0.163-cuda11

# source /share/apps/anaconda3/2020.07/etc/profile.d/conda.sh
source $PYTHON_DIR/bin/activate

which python

nvidia-smi

cd $TARGET

# mkdir -p outputs/slstr_cloud

# sleep 1

cms gpu watch --gpu=0 --delay=0.5 --dense > outputs/gpu0.log &

python slstr_cloud.py --config config_simple.yaml

seff $SLURM_JOB_ID
