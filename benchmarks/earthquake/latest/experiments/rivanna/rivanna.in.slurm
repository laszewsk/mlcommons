#!/usr/bin/env bash
#SBATCH --job-name=mlcommons-eq-{experiment.card_name}-{experiment.gpu_count}
#SBATCH --output=%u-%j.out
#SBATCH --error=%u-%j.err
#SBATCH --partition={system.partition}
#SBATCH --account={system.allocation}
#SBATCH --reservation={system.reservation}
#SBATCH --constraint={system.constraint}
#SBATCH -c {experiment.cpu_num}
#SBATCH --mem={experiment.mem}
#SBATCH --time={time}
#SBATCH --gres=gpu:{experiment.card_name}:{experiment.gpu_count}
#SBATCH --mail-user=%u@virginia.edu
#SBATCH --mail-type=ALL


set -uxe

NB_OUTPUT="_output"

# the path gives you the original path of the slurm job
if [ -n $SLURM_JOB_ID ] ; then
THEPATH=$(scontrol show job $SLURM_JOBID | awk -F= '/Command=/{print $2}')
else
THEPATH=$(realpath $0)
fi

# RUN_BASE="$(echo {run.workdir})"       # $(python eq_lib.py config.yaml run.workdir)

RUN_BASE="{run.filesystem}/mlcommons/{experiment.TFTTransformerepochs}/{experiment.repeat}"
DATA_PATH="$(echo {data.destination}/mlcommons-data-earthquake/data)" # $(python eq_lib.py config.yaml data.destination)
VENV_PATH="$(echo {run.venvpath})"     # $(python eq_lib.py config.yaml run.venvpath)

module purge
module load cuda cudnn

source ${VENV_PATH}/bin/activate

mkdir -p ${RUN_BASE}

if [ -e "$(pwd)/config.yaml" ]; then
  cp $(pwd)/config.yaml ${RUN_BASE}
fi

if [ ! -e "${RUN_BASE}/data" ]; then
  cp -a $DATA_PATH ${RUN_BASE}
fi

#if [ ! -e "${RUN_BASE}/{code.script}" ]; then
  cp -a ../../../../{code.script} .
  cp -a ./{code.script} ${RUN_BASE}/{code.script}
#fi

OUTPUT_NB_NAME="$(basename {code.script} .ipynb)_output.ipynb"


echo "Working in <$(pwd)>"
echo "Running Directory in <${RUN_BASE}>"
echo "Experiment Data Directory: <${DATA_PATH}>"
echo "Repository Revision: <$(git rev-parse HEAD) >"
echo "Notebook Script: <{code.script}>"
echo "Python Version: <$(python -V)>"
echo "Running on host: <$(hostname -a)>"

cms gpu watch --gpu=0 --delay=1 --dense > gpu0.log &

# Execute the notebook using papermill
papermill "${RUN_BASE}/{code.script}" \
          "${RUN_BASE}/$(basename '{code.script}' .ipynb)_output.ipynb" \
          --no-progress-bar --log-output --log-level INFO

echo "Retrieving outputs to ${NB_OUTPUT}"
mkdir -p ${NB_OUTPUT}
cp -R "${RUN_BASE}/data/EarthquakeDec2020/Outputs" ${NB_OUTPUT}
cp "${RUN_BASE}/${OUTPUT_NB_NAME}" "${OUTPUT_NB_NAME}"

# putting output notebook in job dir
cp "${RUN_BASE}/${OUTPUT_NB_NAME}" "$(dirname $THEPATH)/${OUTPUT_NB_NAME}"

echo "Execution Complete"
echo "Cleaning up workspace"
# perform a safe delete; if variables become unset, this will delete ./$USERNAME/./, which should fall
# through.  This is a safety measure to prevent unbounded deletion errors.
# Workspace
rm -rf --preserve-root ${RUN_DIR:-.}/{code.script}
rm -rf --preserve-root ${RUN_DIR:-.}/data
rm -rf --preserve-root ${RUN_DIR:-.}/config.yaml

echo "Cleanup complete"

exit 0

