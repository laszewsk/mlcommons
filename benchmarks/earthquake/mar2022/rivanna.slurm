#!/usr/bin/env bash
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

PYTHON_MAJ="3.10"
PYTHON_MIN="2"

RUNSTAMP="${RUNSTAMP:-${SLURM_JOBID}-$(date +%s)}"
BRANCH="${BRANCH:-main}"
FORK=${FORK:-"laszewsk"}

BASE=${BASE:-/scratch/$USER/${RUNSTAMP}}
HOME=${BASE}

REV="mar2022"
VARIANT="${VARIANT:-gregor}"

RESOURCE_DIR="/project/ds6011-sp22-002"


TFT_EPOCHS=2

echo "Working in <$(pwd)>"
echo "Run Timestamp <${RUNSTAMP}>"
echo "Base directory in <${BASE}>"
echo "Overridden home in <${HOME}>"
echo "Revision: <${REV}>"
echo "Variant: <${VARIANT}>"
echo "Python: <${PYTHON_MAJ}.${PYTHON_MIN}>"
echo "GPU: <${GPU_TYPE}>"

if command -v sbatch ; then
  echo "Slurm Environment Details"
  echo "===start[env]==========="
  printenv | grep "SLURM_"
  echo "===end[env]============="
fi

if [ ! -e "${BASE}/mlcommons-data-earthquake" ]; then
    git clone https://github.com/laszewsk/mlcommons-data-earthquake.git "${BASE}/mlcommons-data-earthquake"
else
    (cd ${BASE}/mlcommons-data-earthquake && \
        git fetch origin && \
        git checkout main && \
        git reset --hard origin/main && \
        git clean -d --force)
fi

if [ ! -e "${BASE}/mlcommons" ]; then
    git clone https://github.com/${FORK}/mlcommons.git "${BASE}/mlcommons"
    (cd ${BASE}/mlcommons && git checkout ${BRANCH})
else
    (cd ${BASE}/mlcommons ; \
        git fetch origin ; \
        git checkout ${BRANCH} ; \
        git reset --hard origin/${BRANCH} ; \
        git clean -d --force)
fi

# Load cuda on HPCs if module is present.
if command -v module ; then
  module purge
  module use ${RESOURCE_DIR}/modulefiles
  module load python-rivanna/${PYTHON_MAJ}.${PYTHON_MIN} cuda cudnn
fi

nvidia-smi

mkdir -p ${BASE}
cd ${BASE}


echo "ENV3 Setup"
python -m venv --prompt ENV3 ${BASE}/ENV3
source ${BASE}/ENV3/bin/activate
python -m pip install -U pip wheel --progress-bar off

if [ ! -e ${BASE}/mlcommons/benchmarks/earthquake/data/EarthquakeDec2020 ]; then
    tar Jxvf ${BASE}/mlcommons-data-earthquake/data.tar.xz \
        -C ${BASE}/mlcommons/benchmarks/earthquake
    # BUG; should be in zip file (or created as part of the python file
    mkdir -p ${BASE}/mlcommons/benchmarks/earthquake/data/EarthquakeDec2020/Outputs
fi


(cd ${BASE}/mlcommons/benchmarks/earthquake/${REV} && \
    python -m pip install -r requirements.txt --progress-bar off)

printenv > ${BASE}/env.source

(cd ${BASE}/mlcommons/benchmarks/earthquake/${REV} && \
    cp "FFFFWNPFEARTHQ_newTFTv29${VARIANT}.ipynb" FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb)
(cd mlcommons/benchmarks/earthquake/mar2022 && \
    papermill "FFFFWNPFEARTHQ_newTFTv29-${USER}.ipynb" "FFFFWNPFEARTHQ_newTFTv29-${USER}-${GPU_TYPE}.ipynb" \
       --no-progress-bar --log-output --log-level INFO)
#       -p TFTTransformerepochs $TFT_EPOCHS \

END_TIME="$(date +%s)"

if [[ ! -z "${SLURM_JOBID}" ]] ; then
  sacct -j ${SLURM_JOBID} -P --delimiter=, -o jobid,user,submit,start,end,state | sed -e 's/^/# slurmjob,/g' -e 's/,Unknown,RUNNING$/,'$(date +%Y-%m-%dT%H:%m:%s -d ${END_TIME})'DONE/g'
fi