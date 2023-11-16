#!/bin/bash
#

# ####################################
# Runtime Variable
# ####################################

# Array of epochs and times required for jobs
# epochsArray=(1 5 10 20 30 50 80 100)
# timesArray=("00:30:00" "00:40:00" "00:50:00" "01:10:00" "01:30:00" "02:30:00" "3:00:00" "4:00:00")
epochsArray=(1 2)
timesArray=("00:30:00" "00:40:00")
REPEAT=5

# GPU

GPU = "v100"

#
# #####################################

# Experiments with v100, 1 GPU

# Initial setup for paths of Log files in config_simple.yaml
sed -i 's/log_file:.*/log_file: \.\/cloudmask_v100_gpu_1.log/' config_simple.yaml
sed -i 's/mlperf_logfile:.*/mlperf_logfile: \.\/mlperf_cloudmask_v100_gpu_1.log/' config_simple.yaml

# Initial setup for gpu and time for one epoch in simple.slurm file
sed -i 's/--gres=.*/--gres=gpu:v100:1/' simple.slurm

# Initial setup for parameters in config_simple.yaml
sed -i 's/card_name.*/card_name: v100/' config_simple.yaml
sed -i 's/gpu_count.*/gpu_count: 1/' config_simple.yaml



# Running 5 jobs and then waiting for them to complete before other commands
for((i=1; i<6; i++)); do
    for j in ${!epochsArray[@]}; do
        sed -i 's/epoch:.*/epoch: '"${epochsArray[$j]}"'/' config_simple.yaml
        sed -i 's/--job-name=.*/--job-name=cloudmask-gpu-greene-epoch-'"${epochsArray[$j]}"'/' simple.slurm
        sed -i 's/--time=.*/--time='"${timesArray[$j]}"'/' simple.slurm

        # Creating temporary copies
        cp config_simple.yaml config_simple_${j}_epochs_${i}.yaml
        cp simple.slurm simple_${j}_epochs_${i}.slurm
    
        # Editing and running them
        sed -i 's/repeat:.*/repeat: "'"$i"'"/' config_simple_${j}_epochs_${i}.yaml
        sed -i 's/--config config_simple\.yaml*/--config config_simple_'"${j}"'_epochs_'"${i}"'\.yaml/g' simple_${j}_epochs_${i}.slurm
        
                
        sbatch --dependency=singleton simple_${j}_epochs_${i}.slurm
    done;
done;

