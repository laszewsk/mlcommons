#!/bin/bash
#
# significantly modified by Gregor von Laszewski
#

# Check if a parameter is provided
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

epochsArray=(2)
timesArray=("00:30:00")
REPEAT=1
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


SCRIPT="simple.slurm"
CONFIG="config_simple.yaml"

REPLACE_YAML="./bin/replace_yaml_value.py"
REPLACE_SLURM="./bin/replace_slurm_value.py"
REPLACE_TEXT="./bin/replace_text.py"

for((i=1; i<=$REPEAT; i++)); do
    for j in ${!epochsArray[@]}; do
        EXPERIMENT_ID=${epochsArray[$j]}_epochs_${i}_$REPEAT
        CONFIG_YAML=config_simple_${EXPERIMENT_ID}.yaml
        SLURM_SCRIPT=simple_${EXPERIMENT_ID}.slurm

        cp $SCRIPT $SLURM_SCRIPT

        # Creating script and config copies
        cp $CONFIG $CONFIG_YAML

        # Modifying the copies
        print_header $EXPERIMENT_ID

        # Modify the config file
        $REPLACE_YAML $CONFIG_YAML experiment.epoch: "${epochsArray[$j]}"
        $REPLACE_YAML $CONFIG_YAML log_file "./cloudmask_${EXPERIMENT_ID}.log"
        $REPLACE_YAML $CONFIG_YAML mlperf_logfile "./mlperf_cloudmask_${EXPERIMENT_ID}.log"
        $REPLACE_YAML $CONFIG_YAML experiment.repeat $i
        $REPLACE_YAML $CONFIG_YAML experiment.card_name ${GPU}
        $REPLACE_YAML $CONFIG_YAML experiemnet.gpu_count 1

        # modify the slurm script
        $REPLACE_SLURM $SLURM_SCRIPT gres "gpu:${GPU}:1"
        $REPLACE_SLURM $SLURM_SCRIPT job-name "cloudmask-gpu-greene-epoch-${EXPERIMENT_ID}"
        $REPLACE_SLURM $SLURM_SCRIPT time "${timesArray[$j]}"

        $REPLACE_TEXT $SLURM_SCRIPT gpu0.log "gpu0-${EXPERIMENT_ID}.log"
        $REPLACE_TEXT $SLURM_SCRIPT $CONFIG $CONFIG_YAML


        # RUN

        if [ "$RUN" = "1" ]; then
          sbatch simple_${EXPERIMENT_ID}.slurm
        else
          print_header simple_${EXPERIMENT_ID}.slurm
          cat simple_${EXPERIMENT_ID}.slurm

          print_header $CONFIG_YAML
          cat $CONFIG_YAML

          print_header "FlatDict $CONFIG_YAML"
          ./bin/print_flatdict.py $CONFIG_YAML

	  
        fi

    done;
done;

