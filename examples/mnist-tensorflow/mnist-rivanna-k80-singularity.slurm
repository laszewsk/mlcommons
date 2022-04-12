#!/usr/bin/env bash
#SBATCH -J mnist
#SBATCH -o mnist-k80.out
#SBATCH -e mnist-k80.err
#SBATCH -p gpu
#SBATCH -c 1
#SBATCH -t 00:01:00
#SBATCH --gres=gpu:k80:1
#SBATCH -A bii_dsc

module purge
module load singularity
module load anaconda

# conda create -y -n py3.10 python=3.10
source activate py3.10
python -V
PYTHON=`which python`

lscpu

nvidia-smi

# Assuming that the container has been copied to the user's /scratch directory
workdir=/scratch/$USER/rivanna
#time singularity run --nv $workdir/tensorflow-2.7.0.sif $PYTHON mnist.py
time singularity run --nv $workdir/tensorflow-2.7.0.sif mnist.py

