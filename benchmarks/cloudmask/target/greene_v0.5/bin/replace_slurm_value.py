#!/usr/bin/env python

import re
import sys
from docopt import docopt

# Usage string for docopt
USAGE = """
Replace variables in a Slurm job script.

Usage:
  replace_slurm_variable.py <file_path> <variable_name> <new_value>
  replace_slurm_variable.py -h | --help

Options:
  -h --help               Show this help message and exit.
"""

# Function to replace a Slurm variable in a file
def replace_slurm_variable(file_path, variable_name, new_value):
    with open(file_path, 'r') as job_script:
        content = job_script.read()

    pattern = re.compile(f'--{variable_name}=\\S+')
    content = pattern.sub(f'--{variable_name}={new_value}', content)

    with open(file_path, 'w') as job_script:
        job_script.write(content)

if __name__ == '__main__':
    arguments = docopt(USAGE)

    file_path = arguments['<file_path>']
    variable_name = arguments['<variable_name>']
    new_value = arguments['<new_value>']

    replace_slurm_variable(file_path, variable_name, new_value)
