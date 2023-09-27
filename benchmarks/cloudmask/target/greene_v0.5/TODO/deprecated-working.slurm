#!/bin/bash
#
#SBATCH --job-name=Cloudmask-GPU-Greene
#SBATCH --nodes=1
#SBATCH --gres=gpu:a100:1
#SBATCH --time=00:30:00
#SBATCH --mem=64G
#SBATCH -o outputs/%j.out
#SBATCH -e outputs/%j.err

module purge
module load anaconda3/2020.07
module load cudnn/8.6.0.163-cuda11

source /share/apps/anaconda3/2020.07/etc/profile.d/conda.sh;
conda activate /scratch/vc2209/TestEnv;
export PATH=/scratch/vc2209/TestEnv/bin:$PATH;

python slstr_cloud.py --config /scratch/vc2209/science/benchmarks/cloudmask/cloudMaskConfig.yaml
