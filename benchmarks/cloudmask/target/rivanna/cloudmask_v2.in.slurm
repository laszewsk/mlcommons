#!/usr/bin/env bash

#SBATCH --job-name={experiment.card_name}-cloudmask-{experiment.epoch}-{experiment.repeat}
#SBATCH --output={experiment.card_name}-{experiment.epoch}-{experiment.repeat}-cloudmask-%u-%j.out
#SBATCH --error={experiment.card_name}-{experiment.epoch}-{experiment.repeat}-cloudmask-%u-%j.err
{slurm.sbatch}
#SBATCH -c {experiment.cpu_num}
#SBATCH --mem={experiment.mem}
#SBATCH --gres=gpu:{experiment.card_name}:{experiment.gpu_count}
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=%u@virginia.edu
#SBATCH --mail-type=ALL
#SBATCH --time={sbatch.time}


# xSBATCH --partition=gpu
# xSBATCH --mem=64GB


PROGRESS () {
    echo "# ###########################################"
    echo "# cloudmesh status="$1" progress=$2 pid=$$"
    echo "# ###########################################"
}

PROGRESS "running" 1

echo "# ==================================="
echo "# SLURM info"
echo "# ==================================="

echo USER {os.USER}
echo HOME {os.HOME}
echo cardname {experiment.card_name}
echo gpu count {experiment.gpu_count}
echo epoc {experiment.epoch}
echo repeat {experiment.repeat}
echo jobno $SLURM_JOB_ID
echo {slurm.sbatch}
echo cpu num {experiment.cpu_num}
echo mem {experiment.mem}
echo USER $USER

PROGRESS "running" 2

echo "# ==================================="
echo "# Set up file system"
echo "# ==================================="

#
# PYTHON with cms on rivanna
#

export PYTHON_DIR=$HOME/ENV3
#export PYTHON_DIR=$USER_SCRACTH/ENV3

#
# CODE
#
export USER_SCRATCH=/scratch/$USER
export PROJECT_DIR=$USER_SCRATCH/mlcommons/benchmarks/cloudmask
export CODE_DIR=$PROJECT_DIR/target/rivanna
export CONTAINERDIR=${CODE_DIR}

export OUTPUTS_DIR="${CODE_DIR}/project/{sbatch.identifier}/outputs"

#
# DATA
#

export PROJECT_DATA=/project/bii_dsc_community/mlcommons/data/cloudmask/



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


mkdir -p $OUTPUTS_DIR

PROGRESS "running" 4


# ####################################################################################################
# MODULE LOAD
# ####################################################################################################

echo "# cloudmesh status=running progress=2 pid=$$"

module purge
module load singularity

PROGRESS "running" 4

source $PYTHON_DIR/bin/activate

which python

PROGRESS "running" 6

# ####################################################################################################
# PROJECT ENVIRONMENT
# ####################################################################################################

echo "# cloudmesh status=running progress=5 pid=$$"

echo "Working in Directory:      $(pwd)"
echo "Repository Revision:       $(git rev-parse HEAD)"
echo "Python Version:            $(python -V)"
echo "Running on host:           $(hostname -a)"

PROGRESS "running" 7

# ####################################################################################################
# GPU environment
# ####################################################################################################

nvidia-smi

PROGRESS "running" 8

echo "# ==================================="
echo "# go to codedir"
echo "# ==================================="

# cd $CODE_DIR


PROGRESS "running" 9

echo "# ==================================="
echo "# check filesystem"
echo "# ==================================="
pwd
ls
singularity exec --nv $CONTAINERDIR/cloudmask.sif bash -c "python -c \"import os; os.system('ls')\""

PROGRESS "running" 10

# ####################################################################################################
# CLOUDMASK
# ####################################################################################################

PROGRESS "running" 20


echo "# ==================================="
echo "# start gpu log"
echo "# ==================================="

cms gpu watch --gpu=0 --delay=0.5 --dense > project/{sbatch.identifier}/gpu0-{experiment.card_name}-$USER-$SLURM_JOB_ID.log &

PROGRESS "running" 21

echo "# ==================================="
echo "# start cloudmask"
echo "# ==================================="

singularity exec --nv $CONTAINERDIR/cloudmask.sif bash -c "python cloudmask_v2.py --config=config.yaml"

PROGRESS "running" 99

seff $SLURM_JOB_ID

PROGRESS "done" 100

echo "Execution Complete"

#
exit 0

