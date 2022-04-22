#!/usr/bin/env bash

#SBATCH --job-name=mlcommons-science-earthquake-k80-2
#SBATCH --output=mlcommons-science-earthquake-k80-2.out
#SBATCH --error=mlcommons-science-earthquake-k80-2.err
#SBATCH --partition=gpu
#SBATCH --cpus-per-task=6
#SBATCH --mem=32G
#SBATCH --time=3-00:00:00
#SBATCH --gres=gpu:k80:1
#SBATCH --account=ds6011-sp22-002

echo "=============================================================================================================="
echo "SLURM_JOB_ID:" $SLURM_JOB_ID
echo "SLURM_JOB_NAME:" $SLURM_JOB_NAME
echo "SLURM_JOB_PARTITION:" $SLURM_JOB_PARTITION
echo "SLURMD_NODENAME:" $SLURMD_NODENAME
echo "=============================================================================================================="

# record top ond gpustat output
# ./sampleTop2.sh thf2bn ${SLURM_JOB_ID} 10 &

EPOCH=2
PARTITION=gpu
GPU_TYPE="k80"
PYTHON_VERSION="3.10.2"
RESOURCE_DIR="/project/ds6011-sp22-002"
RESULTS_DIR=${USER}/output

# BASE=/scratch/$USER/${GPU_TYPE}
BASE=${RESOURCE_DIR}/$USER/${GPU_TYPE}/${EPOCH}
HOME=${BASE}

REV="mar2022"
VARIANT="-gregor-parameters"

echo "Working in <$(pwd)>"
echo "Base directory in <${BASE}>"
echo "Overridden home in <${HOME}>"
echo "Revision: <${REV}>"
echo "Variant: <${VARIANT}>"
echo "Python: <${PYTHON_VERSION}>"
echo "GPU: <${GPU_TYPE}>"

module load cuda cudnn

nvidia-smi

rm -rf /project/ds6011-sp22-002/${USER}/${GPU_TYPE}/${EPOCH}
mkdir -p ${BASE}
cd ${BASE}

if [ ! -e "${BASE}/.local/python/${PYTHON_VESRION}" ] ; then
    tar Jxvf "${RESOURCE_DIR}/python-${PYTHON_VERSION}.tar.xz" -C "${BASE}"
fi

export LD_LIBRARY_PATH=${BASE}/.local/ssl/lib:$LD_LIBRARY_PATH
echo "Python setup"

if [ ! -e "${BASE}/ENV3/bin/activate" ]; then
    ${BASE}/.local/python/${PYTHON_VERSION}/bin/python3.10 -m venv ${BASE}/ENV3
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

# prg >> xyz.out &

(cd ${BASE}/mlcommons/benchmarks/earthquake/${REV} && \
    cp "FFFFWNPFEARTHQ_newTFTv29${VARIANT}.ipynb" FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb)
(cd mlcommons/benchmarks/earthquake/mar2022 && \
    papermill FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb FFFFWNPFEARTHQ_newTFTv29-$USER-$GPU_TYPE-$PARTITION.ipynb --no-progress-bar --log-output --log-level INFO)
echo "JOB COMPLETE"
mkdir -p ${OUTPUT}
cp -r ${BASE} ${OUTPUT}
echo "SAVING JOB COMPLETED" 
echo "=============================================================================================================="
printenv | grep "SLURM_"
echo "=============================================================================================================="
#
