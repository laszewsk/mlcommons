#!/usr/bin/env bash
#SBATCH --job-name=mlcommons-cloudmask-{experiment.card_name}-{experiment.gpu_count}-%j
#SBATCH --output=cloudmask-%j.log
#SBATCH --error=cloudmask-%j.error
#SBATCH --partition={system.partition}
#SBATCH --account={system.allocation}
#SBATCH --reservation={system.reservation}
#SBATCH --constraint={system.constraint}
#SBATCH -c {experiment.cpu_num}
#SBATCH --mem={experiment.mem}
#SBATCH --gres=gpu:{experiment.card_name}:{experiment.gpu_count}
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=%u@virginia.edu
#SBATCH --mail-type=ALL

# #SBATCH --partition=gpu
# #SBATCH --mem=64GB
# #SBATCH --time=6:00:00

set -uxe

RUN_BASE="{run.filesystem}/mlcommons/{experiment.epoch}/{experiment.repeat}"

if [ -n $SLURM_JOB_ID ] ; then
THEPATH=$(scontrol show job $SLURM_JOBID | awk -F= '/Command=/{print $2}')
else
THEPATH=$(realpath $0)
fi

## to run this say sbatch rivanna.sh

cd ~

conda init bash
conda activate MLBENCH

module load singularity tensorflow/2.8.0
module load cudatoolkit/11.0.3-py3.8
module load cuda/11.4.2
module load cudnn/8.2.4.15
module load anaconda/2020.11-py3.8
module load gcc

echo "# cloudmesh status=running progress=1 pid=$$"

# cd /project/bii_dsc/cloudmask/science/benchmarks/cloudmask

#currentgpu=$(echo $(cms set currentgpu) | sed -e "s/['\"]//g" -e "s/^\(currentgpu=\)*//")
#currentepoch=$(echo $(cms set currentepoch) | sed -e "s/['\"]//g" -e "s/^\(currentepoch=\)*//")

# python run_all_rivanna.py
cd /scratch/$USER/mlcommons/benchmarks/cloudmask/experiments
# python -m rivanna.slstr_cloud --config ./rivanna/cloudMaskConfig.yaml > output_$(echo $currentgpu)_$(echo $currentepoch).log 2>&1

cms gpu watch --gpu=0 --delay=1 --dense > gpu0.log &

conda run --no-capture-output \
      -n MLBENCH python \
      -m ubuntu-sh.slstr_cloud \
      --config ./ubuntu-sh/cloudMaskConfig.yaml \
      > $THEPATH/output.log 2>&1

# python mnist_with_pytorch.py > mnist_with_pytorch_py_$(echo $currentgpu).log 2>&1

echo "# cloudmesh status=done progress=100 pid=$$"

# python mlp_mnist.py


#####################################################################################################
##
## EQ FROM HERE ON
##
#
#
#NB_OUTPUT="_output"
#
## RUN_BASE="$(echo {run.workdir})"       # $(python eq_lib.py config.yaml run.workdir)
#
##RUN_BASE="{run.filesystem}/mlcommons/{experiment.TFTTransformerepochs}/{experiment.repeat}"
##DATA_PATH="$(echo {data.destination}/mlcommons-data-earthquake/data)" # $(python eq_lib.py config.yaml data.destination)
##VENV_PATH="$(echo {run.venvpath})"     # $(python eq_lib.py config.yaml run.venvpath)
##
##source ${VENV_PATH}/bin/activate
#
#mkdir -p ${RUN_BASE}
#
#if [ -e "$(pwd)/config.yaml" ]; then
#  cp $(pwd)/config.yaml ${RUN_BASE}
#fi
#
#if [ ! -e "${RUN_BASE}/data" ]; then
#  cp -a $DATA_PATH ${RUN_BASE}
#fi
#
##if [ ! -e "${RUN_BASE}/{code.script}" ]; then
#  cp -a ../../../../{code.script} .
#  cp -a ./{code.script} ${RUN_BASE}/{code.script}
##fi
#
#OUTPUT_NB_NAME="$(basename {code.script} .ipynb)_output.ipynb"
#
#
#echo "Working in <$(pwd)>"
#echo "Running Directory in <${RUN_BASE}>"
#echo "Experiment Data Directory: <${DATA_PATH}>"
#echo "Repository Revision: <$(git rev-parse HEAD) >"
#echo "Notebook Script: <{code.script}>"
#echo "Python Version: <$(python -V)>"
#echo "Running on host: <$(hostname -a)>"
#
#cms gpu watch --gpu=0 --delay=1 --dense > gpu0.log &
#
## Execute the notebook using papermill
#papermill "${RUN_BASE}/{code.script}" \
#          "${RUN_BASE}/$(basename '{code.script}' .ipynb)_output.ipynb" \
#          --no-progress-bar --log-output --log-level INFO
#
#echo "Retrieving outputs to ${NB_OUTPUT}"
#mkdir -p ${NB_OUTPUT}
#cp -R "${RUN_BASE}/data/EarthquakeDec2020/Outputs" ${NB_OUTPUT}
#cp "${RUN_BASE}/${OUTPUT_NB_NAME}" "${OUTPUT_NB_NAME}"
#
#echo "Execution Complete"
#echo "Cleaning up workspace"
## perform a safe delete; if variables become unset, this will delete ./$USERNAME/./, which should fall
## through.  This is a safety measure to prevent unbounded deletion errors.
## Workspace
#rm -rf --preserve-root ${RUN_DIR:-.}/{code.script}
#rm -rf --preserve-root ${RUN_DIR:-.}/data
#rm -rf --preserve-root ${RUN_DIR:-.}/config.yaml
#
#echo "Cleanup complete"
#
#exit 0

