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

banner()
{
  echo "# --------------------------------------------------------------------------------+"
  printf "# `tput bold` %-78s `tput sgr0`|\n" "$@"
  echo "# --------------------------------------------------------------------------------+"
}

RIVANNA=1

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


if [ $RIVANNA -eq 1 ] ; then
    banner "module load"
    module purge
    module load singularity
    module load anaconda
fi

banner "activate python"

if [ $RIVANNA -eq 1 ] ; then
    ## conda create -y -n py3.10 python=3.10
    source activate py3.10
fi

if [ $RIVANNA -eq 0 ]; then
    source ~/ENV3/bin/activate
fi

PYTHON=`which python`
PYTHON_VERSION=`${PYTHON} --version`
PWD=`pwd`


if [ $RIVANNA -eq 1 ] ; then
    PROJ=/project
fi

if [ $RIVANNA -eq 0 ]; then
    PROJ=/projects
fi


IMAGENAME=gregor-tensoflow.sif
SHARE=${PROJ}/ds6011-sp22-002/EQ/share
PROJECT=${PROJ}/ds6011-sp22-002/EQ
EXPERIMENT=$PROJECT/$USER/${EXPERIMENT_NAME}/${GPU_TYPE}
IMAGE=/project/ds6011-sp22-002/EQ/share/$IMAGENAME}

REV="mar2022"
VARIANT="-gregor"

echo "=========================================================="
echo "PWD:        ${PWD}"
echo "PROJECT:    ${PROJECT}"
echo "SHARE:      ${SHARE}"
echo "EXPERIMENT: ${EXPERIMENT}"
echo "REV:        ${REV}"
echo "VARIANT:    ${VARIANT}"
echo "PYTHON:     ${PYTHON}"
echo "PYTHONV:    ${PYTHON_VERSION}"
echo "GPU_TYPE:   ${GPU_TYPE}"
echo "=========================================================="
#ok lscpu
echo "=========================================================="
#ok nvidia-smi
echo "=========================================================="

mkdir -p ${SHARE}
mkdir -p ${PROJECT}


# Assuming that the container has been copied to the user's /scratch directory
#workdir=/scratch/$USER/rivanna
# time singularity run --nv $workdir/tensorflow-2.7.0.sif $PYTHON mnist.py
# time singularity run --nv $workdir/tensorflow-2.7.0.sif mnist.py --log=mnist-a100.log --delay=1.0 --user=Gregor --node=rivanna-a100

banner "ENV3 Setup"

# source ${BASE}/ENV3/bin/activate
python -m pip install -U pip wheel papermill

banner "ENV3 Setup completed"

BASE=$EXPERIMENT

banner "${BASE}/mlcommons-data-earthquake"

if [ ! -e "${BASE}/mlcommons-data-earthquake" ]; then
    git clone https://github.com/laszewsk/mlcommons-data-earthquake.git "${BASE}/mlcommons-data-earthquake"
else
    (cd ${BASE}/mlcommons-data-earthquake ; \
        git fetch origin ; \
        git checkout main ; \
        git reset --hard origin/main ; \
        git clean -d --force)
fi


banner "${BASE}/mlcommons"

if [ ! -e "${BASE}/mlcommons" ]; then
    git clone https://github.com/laszewsk/mlcommons.git "${BASE}/mlcommons"
else
    (cd ${BASE}/mlcommons ; \
        git fetch origin ; \
        git checkout main ; \
        git reset --hard origin/main ; \
        git clean -d --force)
fi

banner "${BASE}/mlcommons/benchmarks/earthquake/data/EarthquakeDec2020"

if [ ! -e ${BASE}/mlcommons/benchmarks/earthquake/data/EarthquakeDec2020 ]; then
    tar Jxvf ${BASE}/mlcommons-data-earthquake/data.tar.xz \
        -C ${BASE}/mlcommons/benchmarks/earthquake
    mkdir -p ${BASE}/mlcommons/benchmarks/earthquake/data/EarthquakeDec2020/outputs
fi

banner "${BASE}/mlcommons/benchmarks/earthquake/${REV}"

(cd ${BASE}/mlcommons/benchmarks/earthquake/${REV} && \
    python -m pip install -r requirements.txt)

banner "copy notebook to ${BASE}/mlcommons/benchmarks/earthquake/${REV}"
(cd ${BASE}/mlcommons/benchmarks/earthquake/${REV} && \
    cp "FFFFWNPFEARTHQ_newTFTv29${VARIANT}.ipynb" FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb)

banner "convert notebook"
(cd ${BASE}/mlcommons/benchmarks/earthquake/${REV} && \
     jupyter nbconvert --to script FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb)

banner "run notebook"

#(cd mlcommons/benchmarks/earthquake/mar2022 && \
#  time singularity run --nv $workdir/tensorflow-2.7.0.sif FFFFWNPFEARTHQ_newTFTv29-$USER.py)
