export GITUSER=laszewsk
export USER_SCRATCH=/scratch/$USER
export PROJECT_DIR=${USER_SCRATCH}/mlcommons/benchmarks/cloudmask
export PROJECT_DATA=${USER_SCRATCH}/data

mkdir -p ${USER_SCRATCH}
mkdir -p ${PROJECT_DATA}
cd $USER_SCRATCH

git clone https://github.com/${GITUSER}/mlcommons.git

cd $PROJECT_DIR

module purge
module load  gcc/9.2.0  cuda/11.0.228  openmpi/3.1.6 python/3.8.8

time python3 -m venv ${USER_SCRATCH}/ENV3
source ${USER_SCRATCH}/ENV3/bin/activate

pip install pip -U
which python

cd ${PROJECT_DIR}/experiments/rivanna
time make requirements

time make data

cd ${PROJECT_DIR}/experiments/rivanna/

