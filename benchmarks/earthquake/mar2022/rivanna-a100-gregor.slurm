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


#  one proposal. lets do what robert does ...
#
#   git clone ....
#   git clone ....
#   ls ./mlcommons
#   ls ./mlcommons-data-earthquake/data.tar.xz
#   tar xvf mlcommons-data-earthquake/data.tar.xz
#   ls ./data/EarthquakeDec2020
#

EXPERIMENT_NAME=experiment-1
GPU_TYPE="a100"

module purge
module load singularity
module load anaconda

# conda create -y -n py3.10 python=3.10
source activate py3.10
PYTHON_VERSION = `python -V`
PYTHON=`which python`


module load singularity

IMAGENAME=gregor-tensoflow.sif
SHARE=/project/ds6011-sp22-002/EQ/share
PROJECT=/project/ds6011-sp22-002/EQ/
EXPERIMENT=$PROJECT/$USER/${EXPERIMENT_NAME}/${GPU_TYPE}
IMAGE=/project/ds6011-sp22-002/EQ/share/$IMAGENAME}

REV="mar2022"
VARIANT="-gregor"

echo "=========================================================="
echo "PWD:      <$(pwd)>"
echo "Project:  <${PROJECT}>"
echo "Revision: <${REV}>"
echo "Variant:  <${VARIANT}>"
echo "Python:   <${PYTHON}>"
echo "Python:   <${PYTHON_VERSION}>"
echo "GPU:      <${GPU_TYPE}>"
echo "=========================================================="
lscpu
echo "=========================================================="
nvidia-smi
echo "=========================================================="


exit

# Assuming that the container has been copied to the user's /scratch directory
workdir=/scratch/$USER/rivanna
#time singularity run --nv $workdir/tensorflow-2.7.0.sif $PYTHON mnist.py
time singularity run --nv $workdir/tensorflow-2.7.0.sif mnist.py --log=mnist-a100.log --delay=1.0 --user=Gregor --node=rivanna-a100




mkdir -p ${BASE}
cd ${BASE}

if [ ! -e "${BASE}/.local/python/${PYTHON_VERSION}" ] ; then
    tar Jxvf "${RESOURCE_DIR}/python-${PYTHON_VERSION}.tar.xz" -C "${BASE}"
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