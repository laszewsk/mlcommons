#!/usr/bin/env bash
#SBATCH --job-name=mlcommons-science-earthquake-p100
#SBATCH --output=mlcommons-science-earthquake-p100.out
#SBATCH --error=mlcommons-science-earthquake-p100.err
#SBATCH --partition=gpu
#SBATCH -c 6
#SBATCH --time=07:00:00
#SBATCH --gres=gpu:p100:1
#SBATCH --account=ds6011-sp22-002

GPU_TYPE="p100"
PYTHON_MAJ="3.10"
PYTHON_MIN="2"

RUNSTAMP="${RUNSTAMP:-$(date +%s)}"
BRANCH="${BRANCH:-main}"
FORK=${FORK:-"laszewsk"}

RESOURCE_DIR="/project/ds6011-sp22-002"

BASE=/scratch/$USER/${GPU_TYPE}-${RUNSTAMP}
HOME=${BASE}

REV="mar2022"
VARIANT="-gregor"

TFT_EPOCHS=2

echo "Working in <$(pwd)>"
echo "Run Timestamp <${RUNSTAMP}>"
echo "Base directory in <${BASE}>"
echo "Overridden home in <${HOME}>"
echo "Revision: <${REV}>"
echo "Variant: <${VARIANT}>"
echo "Python: <${PYTHON_MAJ}.${PYTHON_MIN}>"
echo "GPU: <${GPU_TYPE}>"

# Load cuda on HPCs if module is present.
if command -v module ; then
  module load cuda cudnn
fi

nvidia-smi

mkdir -p ${BASE}
cd ${BASE}

if [ ! -e "${BASE}/.local/python/${PYTHON_MAJ}.${PYTHON_MIN}" ] ; then
    tar Jxvf "${RESOURCE_DIR}/python-${PYTHON_MAJ}.${PYTHON_MIN}.tar.xz" -C "${BASE}"
fi

export LD_LIBRARY_PATH=${BASE}/.local/ssl/lib:$LD_LIBRARY_PATH
echo "Python setup"

if [ ! -e "${BASE}/ENV3/bin/activate" ]; then
    ${BASE}/.local/python/${PYTHON_MAJ}.${PYTHON_MIN}/bin/python3.10 -m venv ${BASE}/ENV3
fi

echo "ENV3 Setup"
source ${BASE}/ENV3/bin/activate
python -m pip install -U pip wheel --progress-bar off

if [ ! -e "${BASE}/mlcommons-data-earthquake" ]; then
    git clone https://github.com/laszewsk/mlcommons-data-earthquake.git "${BASE}/mlcommons-data-earthquake"
else
    (cd ${BASE}/mlcommons-data-earthquake ; \
        git fetch origin ; \
        git checkout main ; \
        git reset --hard origin/main ; \
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

if [ ! -e ${BASE}/mlcommons/benchmarks/earthquake/data/EarthquakeDec2020 ]; then
    tar Jxvf ${BASE}/mlcommons-data-earthquake/data.tar.xz \
        -C ${BASE}/mlcommons/benchmarks/earthquake
    # BUG; should be in zip file (or created as part of the python file
    mkdir -p ${BASE}/mlcommons/benchmarks/earthquake/data/EarthquakeDec2020/Outputs
fi


(cd ${BASE}/mlcommons/benchmarks/earthquake/${REV} && \
    python -m pip install -r requirements.txt --progress-bar off)


(cd ${BASE}/mlcommons/benchmarks/earthquake/${REV} && \
    cp "FFFFWNPFEARTHQ_newTFTv29${VARIANT}.ipynb" FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb)
(cd mlcommons/benchmarks/earthquake/mar2022 && \
    papermill "FFFFWNPFEARTHQ_newTFTv29-${USER}.ipynb" "FFFFWNPFEARTHQ_newTFTv29-${USER}-${GPU_TYPE}.ipynb" \
       -p TFTTransformerepochs $TFT_EPOCHS \
       --no-progress-bar --log-output --log-level INFO)