#!/bin/bash

#SBATCH --job-name=cloudmask-gpu-greene
#SBATCH --nodes=1
#SBATCH --gres=gpu:v100:1
#SBATCH --time=02:00:00
#SBATCH --mem=64G
#SBATCH -o outputs/%j.out
#SBATCH -e outputs/%j.err
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
export PYTHON_DIR=$USER_SCRATCH/ENV3
export PROJECT_DATA=$USER_SCRATCH/data
export CODE_DIR=$PROJECT_DIR/target/greene_v2

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



PROGRESS "running" 4

source $PYTHON_DIR/bin/activate

which python



PROGRESS "running" 6

# 
####################################################################################################
# PROJECT ENVIRONMENT
# 
####################################################################################################

echo "# cloudmesh status=running progress=5 pid=$$"

echo "Working in Directory:      $(pwd)"
echo "Repository Revision:       $(git rev-parse HEAD)"
echo "Python Version:            $(python -V)"
echo "Running on host:           $(hostname -a)"

PROGRESS "running" 7

# 
####################################################################################################
# GPU environment
# 
####################################################################################################


nvidia-smi



PROGRESS "running" 8

echo "# ==================================="
echo "# go to codedir"
echo "# ==================================="

#WHY GO TO RIVANNA DIRECTORY?????
cd $PROJECT_DIR/target/rivanna



PROGRESS "running" 10

# 
####################################################################################################
# CLOUDMASK
# 
####################################################################################################

PROGRESS "running" 20

echo "# ==================================="
echo "# start gpu log"
echo "# ==================================="
cms gpu watch --gpu=0 --delay=0.5 --dense > outputs/gpu0.log &



PROGRESS "running" 21

echo "# ==================================="
echo "# start cloudmask"
echo "# ==================================="

python slstr_cloud.py --config config.yaml

seff $SLURM_JOB_ID

PROGRESS "done" 100

echo "Execution Complete"

#
exit 0
