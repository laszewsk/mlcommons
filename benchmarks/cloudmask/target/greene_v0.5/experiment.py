#!/usr/bin/env python
"""Experiment Generator by Gregor

Usage:
  experiment.py [--debug] [--script=<script>] [--config=<config>] [--clean] [--out=<output>] [--help]

Options:
  -h --help               Show this help message and exit.
  --debug                 Enable debugging mode.
  --script=<script>       Specify the path to the script file [default: simple.slurm].
  --config=<config>       Specify the path to the config file [default: config-simple.yaml].
  --clean                 Clean up generated files.
  --out=<output>          Specify the output filename. If not provided, output will be written to stdout.
"""

import os
import shutil
import sys

from docopt import docopt
from pprint import pprint

arguments = docopt(__doc__)
DEBUG = arguments['--debug']
SCRIPT = arguments['--script'] or "simple.slurm"
CONFIG = arguments['--config'] or "config-simple.yaml"
CLEAN = arguments['--clean']
OUTPUT = arguments['--out']

pprint(arguments)


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

if DEBUG:
    epochsArray = [2]
    timesArray = ["00:30:00"]
    REPEAT = 1

# GPU = "a100"

def clean__files():
    for file_name in os.listdir('.'):
        if file_name.startswith("experiment_") and file_name.endswith(".slurm"):
            os.remove(file_name)
        elif file_name.startswith("experiment_") and file_name.endswith(".yaml"):
            os.remove(file_name)

if CLEAN:
    clean__files()
    sys.exit()

def print_header(header):
    print()
    print("#" + "#" * (len(header) + 2))
    print("#", header)
    print("#" + "#" * (len(header) + 2))
    print()


SLURM_BASE = os.path.basename(SCRIPT).split(".")[0]
CONFIG_BASE = os.path.basename(CONFIG).split(".")[0]

REPLACE_YAML = "./bin/replace_yaml_value.py"
REPLACE_SLURM = "./bin/replace_slurm_value.py"
REPLACE_TEXT = "./bin/replace_text.py"

def replace_in_yaml(config_yaml, key, value):
    os.system(f"{REPLACE_YAML} {config_yaml} {key} \"{value}\"")


def replace_sbatch_in_slurm(slurm_script, key, value):
    os.system(f"{REPLACE_SLURM} {slurm_script} {key} \"{value}\"")


def replace_text(file_to_modify, target_string, replacement_string):
    os.system(f"{REPLACE_TEXT} {file_to_modify} {target_string} \"{replacement_string}\"")

try:
    os.remove(OUTPUT)
except:
    pass

def _print(content):
    print(content)
    if OUTPUT:
        with open(OUTPUT, 'a') as outfile:
            outfile.write(content)
            outfile.write("\n")

for i in range(1, REPEAT + 1):
    for j, epoch in enumerate(epochsArray):

        EXPERIMENT_ID = f"{epoch}_epochs_{i}_{REPEAT}"
        CONFIG_YAML = f"experiment_{CONFIG_BASE}_{EXPERIMENT_ID}.yaml"
        SLURM_SCRIPT = f"experiment_{SLURM_BASE}_{EXPERIMENT_ID}.slurm"

        shutil.copy(SCRIPT, SLURM_SCRIPT)

        # Creating script and config copies
        shutil.copy(CONFIG, CONFIG_YAML)
        # Modifying the copies
        if DEBUG:
            print_header(EXPERIMENT_ID)

        # Modify the config file
        replace_in_yaml(CONFIG_YAML, 'experiment.epoch', epoch)
        replace_in_yaml(CONFIG_YAML, 'log_file', f"./cloudmask_{EXPERIMENT_ID}.log")
        replace_in_yaml(CONFIG_YAML, 'mlperf_logfile', f"./mlperf_cloudmask_{EXPERIMENT_ID}.log")
        replace_in_yaml(CONFIG_YAML, 'experiment.repeat', i)
        replace_in_yaml(CONFIG_YAML, 'experiment.card_name', GPU)
        replace_in_yaml(CONFIG_YAML, 'experiemnet.gpu_count', 1)

        # Modify the slurm script
        replace_sbatch_in_slurm(SLURM_SCRIPT, 'job-name', f"cloudmask-gpu-greene-epoch-{EXPERIMENT_ID}")
        replace_sbatch_in_slurm(SLURM_SCRIPT, 'time', timesArray[j])

        replace_text(SLURM_SCRIPT, 'gpu0.log', f"gpu0-{EXPERIMENT_ID}.log")
        replace_text(SLURM_SCRIPT, CONFIG, CONFIG_YAML)

        # RUN
        if not DEBUG:
            _print(f"sbatch {SLURM_SCRIPT}")
        else:
            print_header(SLURM_SCRIPT)
            with open(SLURM_SCRIPT, 'r') as slurm_file:
                _print(slurm_file.read())

            print_header(CONFIG_YAML)
            with open(CONFIG_YAML, 'r') as config_file:
                _print(config_file.read())

            print_header(f"FlatDict {CONFIG_YAML}")
            os.system(f"./bin/print_flatdict.py {CONFIG_YAML}")

    # The rest of your script remains unchanged from the previous version.
