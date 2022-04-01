#!/usr/bin/env bash -xe
#SBATCH --job-name=mlcommons-science-eq-%u-%j
#SBATCH --output=mlcommons-science-eq-%u-%j.out
#SBATCH --error=mlcommons-science-eq-%u-%j.err
#SBATCH --partition=gpu
#SBATCH -c 6
#SBATCH --time=5:00:00
#SBATCH --gres=gpu:a100:1
#SBATCH --mail-user=%u@virginia.edu
#SBATCH --mail-type=ALL
#SBATCH --account=ds6011-sp22-002

PYTHON_VERSION="3.10.2"

RUNSTAMP={job_run_name}

HOME={job_home}
RUN_DIRECTORY={working_directory}

VENV_PATH=${HOME}/venv-${PYTHON_VERSION}
USER=${USER:-unknown}

REV="mar2022"
VARIANT="${VARIANT:-gregor}"

RESOURCE_DIR="/project/ds6011-sp22-002"

TFT_EPOCHS=2

trap "rm -f ${VENV_PATH}.lock ${HOME}/mlcommons.lock; exit" 1 2 3 6 15


echo "Working in <$(pwd)>"
echo "Run Timestamp <${RUNSTAMP}>"
echo "Base directory in <${RUN_BASE}>"
echo "Overridden home in <${HOME}>"
echo "Revision: <${REV}>"
echo "Variant: <${VARIANT}>"
echo "Python: <${PYTHON_VERSION}>"
echo "GPU: <${GPU_TYPE}>"


if command -v sbatch ; then
  echo "Slurm Environment Details"
  echo "===start[env]==========="
  printenv | grep "SLURM_"
  echo "===end[env]============="
fi

# Load cuda on HPCs if module is present.
if command -v module ; then
  module purge
  module use ${RESOURCE_DIR}/modulefiles
  module load python-rivanna/${PYTHON_VERSION} cuda cudnn
fi

mkdir -p ${RUN_BASE}

RUN_BASE_ABS=$(realpath ${RUN_BASE})

git clone https://github.com/laszewsk/mlcommons-data-earthquake.git "${HOME}/mlcommons-data-earthquake"
git clone https://github.com/laszewsk/mlcommons.git "${HOME}/mlcommons"

GIT_REV="$(cd ${HOME}/mlcommons && git rev-parse --short=8 HEAD)"

mkdir -p ${RUN_BASE}/workspace

nvidia-smi

tar Jxvf ${HOME}/mlcommons-data-earthquake/data.tar.xz -C ${RUN_BASE}
mkdir -p ${RUN_BASE}/data/EarthquakeDec2020/Outputs

python -m venv --upgrade-deps ${VENV_PATH}
source ${VENV_PATH}/bin/activate
python -m pip install -r ${HOME}/mlcommons/benchmarks/earthquake/${REV}/requirements.txt --progress-bar off
cp ${HOME}/mlcommons/benchmarks/earthquake/${REV}/FFFFWNPFEARTHQ_newTFTv29-${VARIANT}.ipynb \
   ${RUN_BASE_ABS}/workspace/FFFFWNPFEARTHQ_newTFTv29-$USER-${GIT_REV}.ipynb)

(cd ${RUN_BASE}/workspace && \
    papermill "FFFFWNPFEARTHQ_newTFTv29-${USER}-${GIT_REV}.ipynb" "FFFFWNPFEARTHQ_newTFTv29-${USER}-${GIT_REV}_output.ipynb" \
       --no-progress-bar --log-output --log-level INFO)