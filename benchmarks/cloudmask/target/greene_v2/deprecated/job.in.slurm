#!/usr/bin/env bash

#SBATCH --job-name={experiment.card_name}-cloudmask-{experiment.epoch}-{experiment.repeat}
#SBATCH --output={experiment.card_name}-{experiment.epoch}-{experiment.repeat}-cloudmask-%u-%j.log
#SBATCH --error={experiment.card_name}-{experiment.epoch}-{experiment.repeat}-cloudmask-%u-%j.err
#SBATCH --partition={system.partition}
#SBATCH --account={system.allocation}
#SBATCH --reservation={system.reservation}
#SBATCH --constraint={system.constraint}
#SBATCH cms --host={system.host} {experiment.card_name}
#SBATCH -c {experiment.cpu_num}
#SBATCH --mem={experiment.mem}
#SBATCH --gres=gpu:{experiment.card_name}:{experiment.gpu_count}
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=%u@virginia.edu
#SBATCH --mail-type=ALL

# xSBATCH --partition=gpu
# xSBATCH --mem=64GB
# xSBATCH --time=6:00:00

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
echo jobno %j
echo partition {system.partition}
echo allocation {system.allocation}
echo reservation {system.reservation}
echo constraint {system.constraint}
echo cpu num {experiment.cpu_num}
echo mem {experiment.mem}
echo %u

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

cd $CODE_DIR

PROGRESS "running" 9

echo "# ==================================="
echo "# check filesystem"
echo "# ==================================="
pwd
ls
singularity exec --nv ./cloudmask.sif bash -c "cd ${CODE_DIR} ; python -c \"import os; os.system('ls')\""

PROGRESS "running" 10

# ####################################################################################################
# CLOUDMASK
# ####################################################################################################

PROGRESS "running" 20


echo "# ==================================="
echo "# start gpu log"
echo "# ==================================="

cms gpu watch --gpu=0 --delay=0.5 --dense > outputs/gpu0-{gpu}-$USER-$SLURM_JOB_ID.log &

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

