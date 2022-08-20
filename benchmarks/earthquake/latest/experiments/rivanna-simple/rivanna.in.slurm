#!/usr/bin/env bash
#SBATCH --job-name=mlcommons-eq-{experiment.card_name}-{experiment.gpu_count}
#SBATCH --output=%u-%j.out
#SBATCH --error=%u-%j.err
#SBATCH --partition={system.partition}
#SBATCH -c {experiment.cpu_num}
#SBATCH --mem={experiment.mem}
#SBATCH --time={time}
#SBATCH --gres=gpu:{experiment.card_name}:{experiment.gpu_count}
#SBATCH --mail-user=%u@virginia.edu
#SBATCH --mail-type=ALL
#SBATCH --account={system.account}

set -uxe

NB_OUTPUT="result"

RUN_BASE="{run.workdir}"         # $(python eq_lib.py config.yaml run.workdir)
DATA_PATH="{data.destination}"   # $(python eq_lib.py config.yaml data.destination)
VENV_PATH="{run.venvpath}"       # $(python eq_lib.py config.yaml run.venvpath)

source ${VENV_PATH}/bin/activate

mkdir -p ${RUN_BASE}

if [ -e "$(pwd)/config.yaml" ]; then
	cp "$(pwd)"/config.yaml ${RUN_BASE}
fi

if [ ! -e "${RUN_BASE}/data" ]; then
  rsync -aV $DATA_PATH ${RUN_BASE}
fi

if [ ! -e "${RUN_BASE}/{script}" ]; then
  cp -a "../../../{script}" {script}
fi

echo "Working in <$(pwd)>"
echo "Running Directory in <${RUN_BASE}>"
echo "Experiment Data Directory: <${DATA_PATH}>"
echo "Repository Revision: <$(git rev-parse HEAD) >"
echo "Notebook Script: <{script}>"
echo "Python Version: <$(python -V)>"

cms gpu watch --gpu=0 --delay=1 --dense > "${RUN_BASE}/data/EarthquakeDec2020/Outputs/gpu0.log" &

# Execute the notebook using papermill
papermill "${RUN_BASE}/{script}" \
          "{script}_output.ipynb" \
          --no-progress-bar --log-output --log-level INFO

echo "Retrieving outputs to ${NB_OUTPUT}"
mkdir -p ${NB_OUTPUT}
cp -R "${RUN_BASE}/data/EarthquakeDec2020/Outputs" ${NB_OUTPUT}

echo "Execution Complete"
echo "Cleaning up workspace"
# perform a safe delete; if variables become unset, this will delete ./$USERNAME/./, which should fall
# through.  This is a safety measure to prevent unbounded deletion errors.
# Workspace
#rm -rf --preserve-root ${RUN_DIR:-.}/{script}
#rm -rf --preserve-root ${RUN_DIR:-.}/data
#rm -rf --preserve-root ${RUN_DIR:-.}/config.yaml

echo "Cleanup complete"

exit 0
