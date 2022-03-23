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

RUNSTAMP="${RUNSTAMP:-${SLURM_JOBID}-$(date +%s)}"
BRANCH="${BRANCH:-main}"
BRANCH_SAFE=${BRANCH/\//-}
FORK=${FORK:-"laszewsk"}

HOME=${BASE:-/project/ds6011-sp22-002/runner/mlcommons/$USER}
RUN_BASE=${RUN_BASE:-${HOME}/${RUNSTAMP}}
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

if [ ! -e "${HOME}/mlcommons-data-earthquake" ]; then
    git clone https://github.com/laszewsk/mlcommons-data-earthquake.git "${HOME}/mlcommons-data-earthquake"
else
    (cd ${HOME}/mlcommons-data-earthquake && \
        git fetch origin && \
        git checkout main && \
        git reset --hard origin/main && \
        git clean -d --force)
fi

printf "Checking for git lock."
while [ -e ${HOME}/mlcommons.lock ] ; do
  printf "."
  sleep 5
done
printf "Done\n"

touch ${HOME}/mlcommons.lock
  if [ ! -e "${HOME}/mlcommons" ]; then
      git clone https://github.com/${FORK}/mlcommons.git "${HOME}/mlcommons"
      (cd ${HOME}/mlcommons && git checkout ${BRANCH})
  else
      (cd ${HOME}/mlcommons ; \
          git fetch origin ; \
          git checkout ${BRANCH} ; \
          git reset --hard origin/${BRANCH} ; \
          git clean -d --force)
  fi
  GIT_REV="$(cd ${HOME}/mlcommons && git rev-parse --short=8 HEAD)"

  mkdir -p ${RUN_BASE}/workspace

  nvidia-smi

  if [ ! -e ${HOME}/mlcommons/benchmarks/earthquake/data/EarthquakeDec2020 ]; then
      tar Jxvf ${HOME}/mlcommons-data-earthquake/data.tar.xz \
          -C ${RUN_BASE}
      # BUG; should be in zip file (or created as part of the python file
      mkdir -p ${RUN_BASE}/data/EarthquakeDec2020/Outputs
  fi

  echo "ENV3 Setup"
  printf "Checking for pip lock."
  while [ -e ${VENV_PATH}.lock ] ; do
    printf "."
    sleep 5
  done
  printf "Done\n"

  touch ${VENV_PATH}.lock
    python -m venv --prompt ENV3 ${VENV_PATH}
    source ${VENV_PATH}/bin/activate
    python -m pip install -U pip wheel --progress-bar off
    (cd ${HOME}/mlcommons/benchmarks/earthquake/${REV} && \
        python -m pip install -r requirements.txt --progress-bar off)
    python -m pip freeze > ${RUN_BASE}/pip-freeze.txt
  rm -f ${VENV_PATH}.lock

  printenv > ${RUN_BASE}/env.source

  (cd ${HOME}/mlcommons/benchmarks/earthquake/${REV} && \
      ls -la "FFFFWNPFEARTHQ_newTFTv29-${VARIANT}.ipynb" && \
      cp "FFFFWNPFEARTHQ_newTFTv29-${VARIANT}.ipynb" ${RUN_BASE_ABS}/workspace/FFFFWNPFEARTHQ_newTFTv29-$USER-${GIT_REV}.ipynb)

rm -f ${HOME}/mlcommons.lock

(cd ${RUN_BASE}/workspace && \
    papermill "FFFFWNPFEARTHQ_newTFTv29-${USER}-${GIT_REV}.ipynb" "FFFFWNPFEARTHQ_newTFTv29-${USER}-${GIT_REV}_output.ipynb" \
       --no-progress-bar --log-output --log-level INFO)
#       -p TFTTransformerepochs $TFT_EPOCHS \

END_TIME="$(date +%s)"

if [[ ! -z "${SLURM_JOBID}" ]] ; then
  sacct -j ${SLURM_JOBID} -P --delimiter=, -o jobid,user,submit,start,end,state | sed -e 's/^/# slurmjob,/g' -e 's/,Unknown,RUNNING$/,'$(date +%Y-%m-%dT%H:%m:%S -d @${END_TIME})'DONE/g'
fi