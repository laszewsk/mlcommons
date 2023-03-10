export GITUSER=laszewsk
export USER_SCRATCH=/scratch/$USER/github-fork
export PROJECT_DIR=$USER_SCRATCH/mlcommons/benchmarks/cloudmask
export PROJECT_DATA=$USER_SCRATCH/data

mkdir -p $USER_SCRATCH
mkdir -p $PROJECT_DATA
cd $USER_SCRATCH

# git clone https://github.com/$GITUSER/mlcommons.git

cd $PROJECT_DIR
