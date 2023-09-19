#!/bin/bash

#SBATCH --job-name=simple-cloudmask-gpu-rivanna
#SBATCH --nodes=1
#SBATCH --gres=gpu:v100:1
#SBATCH --time=06:00:00
#SBATCH --mem=64G
#SBATCH -o outputs/simple-v100-%u-%j.out
#SBATCH -e outputs/simple-v100-%u-%j.err
#SBATCH --partition=bii-gpu
#SBATCH --account=bii_dsc_community

PROGRESS () {
    echo "# ###########################################"
    echo "# cloudmesh status="$1" progress=$2 pid=$$"
    echo "# ###########################################"
}


PROGRESS "running" 1


echo "# ==================================="
echo "# SLURM info"
echo "# ==================================="

# echo USER {os.USER}
# echo HOME {os.HOME}
# echo cardname {experiment.card_name}
# echo gpu count {experiment.gpu_count}
# echo epoc {experiment.epoch}
# echo repeat {experiment.repeat}
echo jobno $SLURM_JOB_ID
# echo partition {system.partition}
# echo allocation {system.allocation}
# echo reservation {system.reservation}
# echo constraint {system.constraint}
# echo cpu num {experiment.cpu_num}
# echo mem {experiment.mem}
echo $USER

PROGRESS "running" 2

echo "# ==================================="
echo "# Set up file system"
echo "# ==================================="


export USER_SCRATCH=/scratch/$USER
export PROJECT_DIR=$USER_SCRATCH/mlcommons/benchmarks/cloudmask
# export PYTHON_DIR=$HOME/ENV3
export PYTHON_DIR=$USER_SCRACTH/ENV3
export PROJECT_DATA=/project/bii_dsc_community/thf2bn/data/cloudmask
export CONTAINERDIR=.

export CODE_DIR=$PROJECT_DIR/target/rivanna

PROGRESS "running" 3


# set -uxe

if [ -n $SLURM_JOB_ID ] ; then
THEPATH=$(scontrol show job $SLURM_JOBID | awk -F= '/Command=/{print $2}')
else
THEPATH=$(realpath $0)
fi
LOCATION=$(dirname $THEPATH)

echo "LOCATION:", $LOCATION
echo "THEPATH:", $THEPATH
echo
echo "USER_SCRATCH: $USER_SCRATCH"
echo "PROJECT_DIR:  $PROJECT_DIR"
echo "PYTHON_DIR:   $PYTHON_DIR"
echo "PROJECT_DATA: $PROJECT_DATA"
echo "CONTAINERDIR: $CONTAINERDIR"

PROGRESS "running" 4

# ####################################################################################################
# MODULE LOAD
# ####################################################################################################

echo "# cloudmesh status=running progress=2 pid=$$"

module purge
module load singularity

# module load  gcc/9.2.0  cuda/11.0.228  openmpi/3.1.6 python/3.8.8
# module load singularity tensorflow/2.8.0

PROGRESS "running" 4

source $PYTHON_DIR/bin/activate

which python

nvidia-smi

PROGRESS "running" 8


echo "# ==================================="
echo "# go to codedir"
echo "# ==================================="

cd $CODE_DIR

PROGRESS "running" 9

echo "# ==================================="
echo "# check filesystem"
echo "# ==================================="
pwd
ls
singularity exec --nv ./cloudmask.sif bash -c "cd ${CODE_DIR} ; python -c \"import os; os.system('ls')\""

PROGRESS "running" 10



echo "# ==================================="
echo "# start gpu log"
echo "# ==================================="

cms gpu watch --gpu=0 --delay=0.5 --dense > outputs/simple-$USER-$SLURM_JOB_ID-gpu0.log &

PROGRESS "running" 21


echo "# ==================================="
echo "# start cloudmask"
echo "# ==================================="

singularity exec --nv ./cloudmask.sif bash -c "cd ${CODE_DIR} ; python cloudmask_v2.py --config=config-new.yaml"

PROGRESS "running" 99

seff $SLURM_JOB_ID

PROGRESS "done" 100

echo "Execution Complete"

#
exit 0

