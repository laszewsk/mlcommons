#!/bin/bash
#

# ####################################
# Runtime Variable
# ####################################

# Array of epochs and times required for jobs

# epochsArray=(1 5 10 20 30 50 80 100 200)
epochsArray=(200)
# timesArray=("00:30:00" "00:40:00" "00:50:00" "01:10:00" "01:30:00" "02:30:00" "3:00:00" "4:00:00" "13:00:00")
timesArray=("13:00:00")
# REPEAT=5
REPEAT=5

# GPU

GPU="v100"
# GPU="a100"

# modified files
slurm_script="tmptest-singularity.slurm"
config_file="config_simple.yaml"

# create directory for new generated files
mkdir slurm_reproduce_files
mkdir config_reproduce_files


#
# #####################################

# Experiments with v100, 1 GPU

# Initial setup for gpu and time for one epoch in simple.slurm file
sed -i 's/--gres=.*/--gres=gpu:'"${GPU}"':1/' $slurm_script

# Initial setup for parameters in config_simple.yaml
sed -i 's/card_name.*/card_name: '"${GPU}"'/' $config_file
sed -i 's/gpu_count.*/gpu_count: 1/' $config_file



# Running 5 jobs and then waiting for them to complete before other commands
for((i=1; i<=$REPEAT; i++)); do
    for j in ${!epochsArray[@]}; do
        sed -i 's/epoch:.*/epoch: '"${epochsArray[$j]}"'/' $config_file
        sed -i 's/--job-name=.*/--job-name=cloudmask-gpu-greene-epoch-'"${epochsArray[$j]}"'/' $slurm_script
        sed -i 's/--time=.*/--time='"${timesArray[$j]}"'/' $slurm_script

        # Creating temporary copies
        cp $config_file config_reproduce_files/config_simple_${epochsArray[$j]}_epochs_${i}.yaml
        cp $slurm_script slurm_reproduce_files/simple_${epochsArray[$j]}_epochs_${i}.slurm

        # Editing paths to log files in the config files
        sed -i 's/log_file:.*/log_file: \.\/cloudmask_'"${epochsArray[$j]}"'_epochs_'"${i}"'.log/' config_reproduce_files/config_simple_${epochsArray[$j]}_epochs_${i}.yaml
        sed -i 's/mlperf_logfile:.*/mlperf_logfile: \.\/mlperf_cloudmask_'"${epochsArray[$j]}"'_epochs_'"${i}"'.log/' config_reproduce_files/config_simple_${epochsArray[$j]}_epochs_${i}.yaml

        # Editing and running them
        sed -i 's/repeat:.*/repeat: "'"$i"'"/' config_reproduce_files/config_simple_${epochsArray[$j]}_epochs_${i}.yaml
        sed -i 's/--config config_simple\.yaml*/--config config_reproduce_files\/config_simple_'"${epochsArray[$j]}"'_epochs_'"${i}"'\.yaml/g' slurm_reproduce_files/simple_${epochsArray[$j]}_epochs_${i}.slurm


        sbatch slurm_reproduce_files/simple_${epochsArray[$j]}_epochs_${i}.slurm
    done;
done;

