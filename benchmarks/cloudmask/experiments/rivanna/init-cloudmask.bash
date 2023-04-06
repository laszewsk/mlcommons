echo "# ------------------------------------------"
echo "# set up exports"
echo "# ------------------------------------------"

export GITUSER=laszewsk
export USER_SCRATCH=/scratch/$USER
export PROJECT_DIR=$USER_SCRATCH/mlcommons/benchmarks/cloudmask
export PROJECT_DATA=$USER_SCRATCH/data

echo "# ------------------------------------------"
echo "# create directories"
echo "# ------------------------------------------"


mkdir -p $USER_SCRATCH
mkdir -p $PROJECT_DATA
cd $USER_SCRATCH

echo "# ------------------------------------------"
echo "# clone the reporsitory"
echo "# ------------------------------------------"

if [ ! -d "mlcommons" ]
then
  git clone https://github.com/$GITUSER/mlcommons.git
  # cd mlcommons
  # git remote set-url origin git@github.com:laszewsk/mlcommons.gi
else
  cd mlcommons
  git pull
fi


echo "# ------------------------------------------"
echo "# set up python"
echo "# ------------------------------------------"

cd $PROJECT_DIR

module purge
module load  gcc/9.2.0  cuda/11.0.228  openmpi/3.1.6 python/3.8.8

time python -m venv $USER_SCRATCH/ENV3
source $USER_SCRATCH/ENV3/bin/activate

pip install pip -U
which python

echo "# ------------------------------------------"
echo "# set up requirements"
echo "# ------------------------------------------"

cd $PROJECT_DIR/experiments/rivanna
time make requirements

echo "# ------------------------------------------"
echo "# get the data"
echo "# ------------------------------------------"


if [ ! -d " ${PROJECT_DATA}/ssts" ]
then
  time make data
  # cd mlcommons
  # git remote set-url origin git@github.com:laszewsk/mlcommons.gi
else
  echo "data dir already exists"
fi


# cd $PROJECT_DIR/experiments/rivanna/

echo "# ------------------------------------------"
echo "# set up finished"
echo "# ------------------------------------------"
