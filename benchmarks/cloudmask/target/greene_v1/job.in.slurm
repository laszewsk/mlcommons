#!/usr/bin/env bash
#SBATCH --job-name=mlcommons-cloudmask-{experiment.card_name}-{experiment.gpu_count}-{experiment.epoch}-{experiment.repeat}
#SBATCH --output=cloudmask-%j.log
#SBATCH --error=cloudmask-%j.error
#SBATCH -c {experiment.cpu_num}
#SBATCH --mem={experiment.mem}
#SBATCH --gres=gpu:{experiment.card_name}:{experiment.gpu_count}
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=%u@nyu.edu
#SBATCH --mail-type=ALL


# #SBATCH --mem=64GB
# #SBATCH --time=6:00:00

echo "# cloudmesh status=running progress=1 pid=$$"

# SAVE DIR


set -uxe

RUN_BASE="{run.filesystem}/mlcommons/{experiment.epoch}/{experiment.repeat}"
DATA_PATH="/scratch/${USER}/mlcommons/benchmarks/cloudmask/data"

if [ -n $SLURM_JOB_ID ] ; then
THEPATH=$(scontrol show job $SLURM_JOBID | awk -F= '/Command=/{print $2}')
else
THEPATH=$(realpath $0)
fi

## to run this say sbatch rivanna.sh

cd ~


# ####################################################################################################
# MODULE LOAD
# ####################################################################################################

echo "# cloudmesh status=running progress=2 pid=$$"


# conda init bash

set +eu
conda activate cloudenv
set -eu
set -uxe

module purge
module load anaconda3/2020.07
module load cudnn/8.6.0.163-cuda11

source /scratch/vc2209/ENV3/bin/activate

# ####################################################################################################
# CLOUDMASK
# ####################################################################################################

echo "# cloudmesh status=running progress=5 pid=$$"

echo "Working in Directory:      $(pwd)"
echo "Running in Directory:      ${RUN_BASE}"
echo "Experiment Data Directory: ${DATA_PATH}"
echo "Repository Revision:       $(git rev-parse HEAD)"
echo "Notebook Script:           {code.script}"
echo "Python Version:            $(python -V)"
echo "Running on host:           $(hostname -a)"


cms gpu watch --gpu=0 --delay=1 --dense > $(dirname $THEPATH)/gpu0.log &


sed -i "/log_file:/c\log_file: $(dirname $THEPATH)/cloudmask_run.log" $(dirname $THEPATH)/config.yaml

sed -i "/mlperf_logfile:/c\mlperf_logfile: $(dirname $THEPATH)/mlperf_cloudmask.log" $(dirname $THEPATH)/config.yaml

sed -i "/model_file:/c\model_file: $(dirname $THEPATH)/cloudModel.h5" $(dirname $THEPATH)/config.yaml


echo "# cloudmesh status=running progress=6 pid=$$"

# cd /project/bii_dsc/cloudmask/science/benchmarks/cloudmask

cd /scratch/$USER/mlcommons/benchmarks/cloudmask/experiments

cms gpu watch --gpu=0 --delay=1 --dense > $(dirname $THEPATH)/gpu0.log &

python -m greene.slstr_cloud --config $(dirname $THEPATH)/config.yaml > $(dirname $THEPATH)/output.log 2>&1

# python slstr_cloud.py --config $(dirname $THEPATH)/config.yaml > $(dirname $THEPATH)/output.log 2>&1

echo "# cloudmesh status=done progress=100 pid=$$"

echo "Execution Complete"

#
exit 0

