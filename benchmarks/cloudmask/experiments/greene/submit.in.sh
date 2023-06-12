#!/bin/bash
#
#SBATCH --job-name=%u-cloudmask-{experiment.cardname}-{experiment.repeat}-%j
#SBATCH --nodes=1
#SBATCH --gres=gpu:{experiment.cardname}:1
#SBATCH --time=00:40:00
#SBATCH --mem=64G
#SBATCH -o outputs/%u-cloudmask-{experiment.cardname}-{experiment.repeat}-%j.out
#SBATCH -e outputs/%u-cloudmask-{experiment.cardname}-{experiment.repeat}-%j.err


experiment:
#  card_name: a100
  card_name: "v100,a100"
  gpu_count: 1
  cpu_num: 1
  mem: "64GB"
  repeat: "1,2"
  epoch: 1,50,100
  seed: "1234"
  learning_rate: 0.001
  batch_size: 32
  train_split: 0.8
  clip_offset: 15
  no_cache: False
  nodes: 1
  gpu: 1


export USER_SCRATCH=/scratch/$USER/github-fork
export PROJECT_DIR=$USER_SCRATCH/mlcommons/benchmarks/cloudmask
export PYTHON_DIR=$USER_SCRATCH/ENV3
export PROJECT_DATA=$USER_SCRATCH/data


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

python slstr_cloud.py --config config.yaml

seff $SLURM_JOB_ID
