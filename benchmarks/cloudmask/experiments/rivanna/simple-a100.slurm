#!/bin/bash
#SBATCH --job-name=a100-cloudmask-gpu-greene
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=2:00:00
#SBATCH --partition=bii-gpu
#SBATCH --account=bii_dsc_community
#SBATCH --gres=gpu:a100
#SBATCH -o outputs/a100-%u-%j.out
#SBATCH -e outputs/a100-%u-%j.err
#SBATCH --reservation=bi_fox_dgx
#SBATCH --constraint=a100_80gb
#SBATCH --mem=64G

export USER_SCRATCH=/scratch/$USER
export PROJECT_DIR=$USER_SCRATCH/mlcommons/benchmarks/cloudmask
export PYTHON_DIR=$USER_SCRATCH/ENV3
export PROJECT_DATA=$USER_SCRATCH/data

echo "# cloudmesh status=running progress=1 pid=$$"
module purge
# module load  gcc/9.2.0  cuda/11.0.228  openmpi/3.1.6 python/3.8.8
module load singularity tensorflow/2.8.0

echo "# cloudmesh status=running progress=2 pid=$$"

source $PYTHON_DIR/bin/activate

which python

echo "# cloudmesh status=running progress=3 pid=$$"
nvidia-smi
echo "# cloudmesh status=running progress=4 pid=$$"

cd $PROJECT_DIR/experiments/rivanna

cms gpu watch --gpu=0 --delay=0.5 --dense > outputs/gpu0.log &
echo "# cloudmesh status=running progress=5 pid=$$"

time singularity run --nv $CONTAINERDIR/tensorflow-2.8.0.sif "python slstr_cloud.py --config simple-config.yaml"



echo "# cloudmesh status=running progress=99 pid=$$"

seff $SLURM_JOB_ID
echo "# cloudmesh status=running progress=100 pid=$$"
