#!/usr/bin/env bash

#SBATCH --job-name=mlcommons-science-earthquake-a100
#SBATCH --output=mlcommons-science-earthquake-a100.out
#SBATCH --error=mlcommons-science-earthquake-a100.err
#SBATCH --partition=gpu
#SBATCH --cpus-per-task=6
#SBATCH --mem=32G
#SBATCH --time=06:00:00
#SBATCH --gres=gpu:a100:1
#SBATCH --account=ds6011-sp22-002

# record top ond gpustat output
./sampleTop2.sh thf2bn ${SLURM_JOB_ID} 10 &


GPU_TYPE="a100"
PYTHON_MAJ="3.10"
PYTHON_MIN="2"

RESOURCE_DIR="/project/ds6011-sp22-002"

# BASE=/scratch/$USER/${GPU_TYPE}
BASE=${RESOURCE_DIR}/$USER/${GPU_TYPE}

HOME=${BASE}

REV="mar2022"
VARIANT="-gregor"

echo "Working in <$(pwd)>"
echo "Base directory in <${BASE}>"
echo "Overridden home in <${HOME}>"
echo "Revision: <${REV}>"
echo "Variant: <${VARIANT}>"
echo "Python: <${PYTHON_MAJ}.${PYTHON_MIN}>"
echo "GPU: <${GPU_TYPE}>"

module load cuda cudnn

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
python -m pip install -U pip wheel papermill

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
    git clone https://github.com/laszewsk/mlcommons.git "${BASE}/mlcommons"
else
    (cd ${BASE}/mlcommons ; \
        git fetch origin ; \
        git checkout main ; \
        git reset --hard origin/main ; \
        git clean -d --force)
fi

if [ ! -e ${BASE}/mlcommons/benchmarks/earthquake/data/EarthquakeDec2020 ]; then
    tar Jxvf ${BASE}/mlcommons-data-earthquake/data.tar.xz \
        -C ${BASE}/mlcommons/benchmarks/earthquake
    mkdir -p ${BASE}/mlcommons/benchmarks/earthquake/data/EarthquakeDec2020/outputs
fi


(cd ${BASE}/mlcommons/benchmarks/earthquake/${REV} && \
    python -m pip install -r requirements.txt)


(cd ${BASE}/mlcommons/benchmarks/earthquake/${REV} && \
    cp "FFFFWNPFEARTHQ_newTFTv29${VARIANT}.ipynb" FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb)
(cd mlcommons/benchmarks/earthquake/mar2022 && \
    papermill FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb FFFFWNPFEARTHQ_newTFTv29-$USER-$GPU_TYPE.ipynb --no-progress-bar --log-output --log-level INFO)
