#!/bin/bash
#

 Check if a parameter is provided
if [ $# -eq 0 ]; then
    # If no parameter is provided, set it to 1
    RUN=1
else
    # Use the provided parameter
    RUN="$1"
fi

# ####################################
# Runtime Variable
# ####################################

# Array of epochs and times required for jobs
epochsArray=(1 5 10 20 30 50 80 100 200)
timesArray=("00:30:00" "00:40:00" "00:50:00" "01:10:00" "01:30:00" "02:30:00" "3:00:00" "4:00:00" "13:00:00")
REPEAT=5

# GPU

GPU="v100"
# GPU="a100"

print_header() {
    echo
    echo "# ###################################################################################"
    echo "# $1"
    echo "# ###################################################################################"
    echo
}

#
# #####################################

# Experiments with v100, 1 GPU

# Initial setup for gpu and time for one epoch in simple.slurm file
sed -i 's/--gres=.*/--gres=gpu:'"${GPU}"':1/' simple.slurm

# Initial setup for parameters in config-simple.yaml
sed -i 's/card_name.*/card_name: '"${GPU}"'/' config-simple.yaml
sed -i 's/gpu_count.*/gpu_count: 1/' config-simple.yaml



# Running 5 jobs and then waiting for them to complete before other commands
for((i=1; i<=$REPEAT; i++)); do
    for j in ${!epochsArray[@]}; do
        sed -i 's/epoch:.*/epoch: '"${epochsArray[$j]}"'/' config-simple.yaml
        sed -i 's/--job-name=.*/--job-name=cloudmask-gpu-greene-epoch-'"${epochsArray[$j]}"'/' simple.slurm
        sed -i 's/--time=.*/--time='"${timesArray[$j]}"'/' simple.slurm

        EXPERIMENT_ID=${epochsArray[$j]}_epochs_${i}

        # Creating temporary copies
        cp config-simple.yaml config_simple_${epochsArray[$j]}_epochs_${i}.yaml
        cp simple.slurm simple_${epochsArray[$j]}_epochs_${i}.slurm
 
        # Editing paths to log files in the config files
        sed -i 's/log_file:.*/log_file: \.\/cloudmask_'"${epochsArray[$j]}"'_epochs_'"${i}"'.log/' config_simple_${epochsArray[$j]}_epochs_${i}.yaml
        sed -i 's/mlperf_logfile:.*/mlperf_logfile: \.\/mlperf_cloudmask_'"${epochsArray[$j]}"'_epochs_'"${i}"'.log/' config_simple_${epochsArray[$j]}_epochs_${i}.yaml
    
        # Editing and running them
        sed -i 's/repeat:.*/repeat: "'"$i"'"/' config_simple_${epochsArray[$j]}_epochs_${i}.yaml
        sed -i 's/--config config_simple\.yaml*/--config config_simple_'"${epochsArray[$j]}"'_epochs_'"${i}"'\.yaml/g' simple_${epochsArray[$j]}_epochs_${i}.slurm
        
        if [ "$RUN" = "1" ]; then
          sbatch simple_${epochsArray[$j]}_epochs_${i}.slurm
        else
          print_header simple_${epochsArray[$j]}_epochs_${i}.slurm
          cat simple_${epochsArray[$j]}_epochs_${i}.slurm

          print_header config_simple_${epochsArray[$j]}_epochs_${i}.yaml
          cat config_simple_${epochsArray[$j]}_epochs_${i}.yaml
	  
        fi

    done;
done;

