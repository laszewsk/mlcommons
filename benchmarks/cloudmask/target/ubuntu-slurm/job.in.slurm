#!/usr/bin/env bash
#SBATCH --job-name=mlcommons-cloudmask-{experiment.card_name}-{experiment.gpu_count}-{experiment.epoch}-{experiment.repeat}
#SBATCH --output=cloudmask-%j.log
#SBATCH --error=cloudmask-%j.error
# #SBATCH --partition={system.partition}
# #SBATCH --account={system.allocation}
# #SBATCH --reservation={system.reservation}
# #SBATCH --constraint={system.constraint}
# #SBATCH -c {experiment.cpu_num}
# #SBATCH --mem={experiment.mem}
# #SBATCH --gres=gpu:{experiment.card_name}:{experiment.gpu_count}
# #SBATCH --cpus-per-task=1
# #SBATCH --mail-user=%u@virginia.edu
# #SBATCH --mail-type=ALL

# #SBATCH --partition=gpu
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

module load anaconda
# conda init bash

set +eu
conda activate cloudenv
set -eu
set -uxe

module load singularity tensorflow/2.8.0
module load cudatoolkit/11.0.3-py3.8
module load cuda/11.4.2
module load cudnn/8.2.4.15
module load anaconda/2020.11-py3.8
module load gcc

source ~/ENV3/bin/activate

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

python -m rivanna.slstr_cloud --config $(dirname $THEPATH)/config.yaml > $(dirname $THEPATH)/output.log 2>&1

# python slstr_cloud.py --config $(dirname $THEPATH)/config.yaml > $(dirname $THEPATH)/output.log 2>&1

echo "# cloudmesh status=done progress=100 pid=$$"

echo "Execution Complete"

#
exit 0

