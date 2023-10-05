#!/bin/bash
#SBATCH --job-name=simple-cloudmask-gpu-rivanna
#SBATCH --nodes=1
#SBATCH --gres=gpu:a100:1
#SBATCH --time=00:45:00
#SBATCH --mem=64G
#SBATCH -o outputs/simple-rivanna-a100-dgx-%u-%j.out
#SBATCH -e outputs/simple-rivanna-a100-dgx-%u-%j.err
#SBATCH --reservation=bi_fox_dgx
#SBATCH --partition=bii-gpu
#SBATCH --account=bii_dsc_community


mkdir -p outputs/slstr_cloud
sleep 1

export USER_SCRATCH=/scratch/$USER
export PROJECT_DIR=$USER_SCRATCH/github/mlcommons/benchmarks/cloudmask
export PYTHON_DIR=$USER_SCRATCH/ENV3
export PROJECT_DATA=$USER_SCRATCH/data/cloudmask/data
export TARGET=$PROJECT_DIR/target/greene_v0.5

module purge
module load gcc/11.2.0  openmpi/4.1.4 python/3.11.1

# source /share/apps/anaconda3/2020.07/etc/profile.d/conda.sh
source $PYTHON_DIR/bin/activate

which python

nvidia-smi

cd $TARGET


# sleep 1

#cms gpu watch --gpu=0 --delay=0.5 --dense > outputs/gpu0.log &

#python ./cloudmask_v0.5.py --config config-simple-rivanna.yaml

singularity exec --nv ./cloudmask.sif bash -c "cd ${TARGET} ; python cloudmask_v0.5.py --config=config-simple-rivanna.yaml"

seff $SLURM_JOB_ID
