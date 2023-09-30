#!/bin/bash

if [ -d archive_results ]
then
    echo "archive_results/ already exists. Skipping mkdir..."
else
    echo "Creating archive_results/ ..."
    mkdir archive_results/
fi

if [ ! -f card_name_* ]
then
    echo "No cloudmodel directory exists in current directory. Terminating..."
    exit 1
fi


mkdir experiment_outputs/

run_date=$1
epoch=$2
repeat=$3
earlystop=no_earlystoppage


if [ $4 -eq 1 ]
then
    earlystop="earlystoppage"
fi


export USER_SCRATCH=/scratch/$USER/github-fork
export PYTHON_DIR=$USER_SCRATCH/ENV3


# This bash script is an automation attempt to archive experiment results.
# WARNING: ONLY USE THIS SCRIPT AFTER RUNNING GRCtest_reproduce_experiments.sh

echo "Moving cloudModel to experiment_outputs/"
mv card_name_*_gpu_count_* experiment_outputs

echo "Aggregating cloudmask logs and mlperf logs into two master logs"
cat cloudmask_$epoch* >> cloudmask_$epoch.log
cat mlperf_cloudmask_$epoch* >> mlperf_cloudmask_$epoch.log

echo "Creating images with visualizer.py; And moving images"
source $PYTHON_DIR/bin/activate
python3 visualizer.py mlperf_cloudmask_$epoch.log cloudmask_$epoch.log
mv images experiment_outputs
 
echo "Moving all log files to experiment_outputs/"
mv cloudmask_$epoch* experiment_outputs
mv mlperf_cloudmask_$epoch* experiment_outputs

echo "Moving outputs/ to experiment_outputs/"
mv outputs experiment_outputs
mkdir -p outputs/slstr_cloud/

echo "Moving generated config files and slurm scripts to experiment_outputs/"
mv config_reproduce_files experiment_outputs
mv slurm_reproduce_files experiment_outputs

echo "Generating archive name and moving it into archive_results/"
archive_dir=$run_date-epoch$epoch-repeat$repeat-$earlystop
mv experiment_outputs $archive_dir
mv $archive_dir archive_results/
