#!/usr/bin/env python
#
# significantly modified by Gregor von Laszewski
#

#!/usr/bin/env python
"""experiment generator

Usage:
  bash_to_python.py [--debug] [--help]

Options:
  -h --help     Show this help message and exit.
  --debug       Enable debugging mode.
"""

import os
import shutil
from docopt import docopt

arguments = docopt(__doc__)
DEBUG = arguments['--debug']

if DEBUG:
    DEBUG = True
else:
    DEBUG = False

# ####################################
# Runtime Variable
# ####################################

# Array of epochs and times required for jobs
epochsArray = [1, 5, 10, 20, 30, 50, 80, 100, 200]
timesArray = ["00:30:00",
              "00:40:00",
              "00:50:00",
              "01:10:00",
              "01:30:00",
              "02:30:00",
              "3:00:00",
              "4:00:00",
              "13:00:00"]
REPEAT = 5

# Modify the arrays for your specific use case
epochsArray = [2]
timesArray = ["00:30:00"]
REPEAT = 1
GPU = "v100"

# GPU = "a100"

def print_header(header):
    print()
    print("#" + "#" * (len(header) + 2))
    print("#", header)
    print("#" + "#" * (len(header) + 2))
    print()

SCRIPT = "simple.slurm"
CONFIG = "config_simple.yaml"

REPLACE_YAML = "./bin/replace_yaml_value.py"
REPLACE_SLURM = "./bin/replace_slurm_value.py"
REPLACE_TEXT = "./bin/replace_text.py"


def replace_in_yaml(config_yaml, key, value):
    os.system(f"{REPLACE_YAML} {config_yaml} {key} \"{value}\"")


def replace_sbatch_in_slurm(slurm_script, key, value):
    os.system(f"{REPLACE_SLURM} {slurm_script} {key} \"{value}\"")


def replace_text(file_to_modify, target_string, replacement_string):
    os.system(f"{REPLACE_TEXT} {file_to_modify} {target_string} \"{replacement_string}\"")

for i in range(1, REPEAT + 1):
    for j, epoch in enumerate(epochsArray):
        EXPERIMENT_ID = f"{epoch}_epochs_{i}_{REPEAT}"
        CONFIG_YAML = f"config_simple_{EXPERIMENT_ID}.yaml"
        SLURM_SCRIPT = f"simple_{EXPERIMENT_ID}.slurm"

        shutil.copy(SCRIPT, SLURM_SCRIPT)

        # Creating script and config copies
        shutil.copy(CONFIG, CONFIG_YAML)

        # Modifying the copies
        print_header(EXPERIMENT_ID)

        # Modify the config file
        replace_in_yaml(CONFIG_YAML, 'experiment.epoch:', epoch)
        replace_in_yaml(CONFIG_YAML, 'log_file', f"./cloudmask_{EXPERIMENT_ID}.log")
        replace_in_yaml(CONFIG_YAML, 'mlperf_logfile', f"./mlperf_cloudmask_{EXPERIMENT_ID}.log")
        replace_in_yaml(CONFIG_YAML, 'experiment.repeat', i)
        replace_in_yaml(CONFIG_YAML, 'experiment.card_name', GPU)
        replace_in_yaml(CONFIG_YAML, 'experiemnet.gpu_count', 1)

        # Modify the slurm script
        replace_sbatch_in_slurm(SLURM_SCRIPT, 'gres', f"gpu:{GPU}:1")
        replace_sbatch_in_slurm(SLURM_SCRIPT, 'job-name', f"cloudmask-gpu-greene-epoch-{EXPERIMENT_ID}")
        replace_sbatch_in_slurm(SLURM_SCRIPT, 'time', timesArray[j])

        replace_text(SLURM_SCRIPT, 'gpu0.log', f"gpu0-{EXPERIMENT_ID}.log")
        replace_text(SLURM_SCRIPT, CONFIG, CONFIG_YAML)


        # RUN
        if DEBUG == 1:
            os.system(f"sbatch {SLURM_SCRIPT}")
        else:
            print_header(SLURM_SCRIPT)
            with open(SLURM_SCRIPT, 'r') as slurm_file:
                print(slurm_file.read())

            print_header(CONFIG_YAML)
            with open(CONFIG_YAML, 'r') as config_file:
                print(config_file.read())

            print_header(f"FlatDict {CONFIG_YAML}")
            os.system(f"./bin/print_flatdict.py {CONFIG_YAML}")



    # The rest of your script remains unchanged from the previous version.

