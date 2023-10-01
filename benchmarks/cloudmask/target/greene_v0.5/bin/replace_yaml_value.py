#!/usr/bin/env python

import oyaml as yaml
from docopt import docopt

# Usage string for docopt
USAGE = """
Replace a value in a hierarchical YAML file and save the result to the same file.

Usage:
  replace_yaml_value.py <file_path> <key_to_replace> <new_value>
  replace_yaml_value.py -h | --help

Options:
  -h --help     Show this help message and exit.
"""

# Function to replace a value in a YAML dictionary
def replace_yaml_value(data, keys, new_value):
    if len(keys) == 1:
        key = keys[0]
        if key in data:
            data[key] = new_value
    else:
        key = keys[0]
        if key in data:
            replace_yaml_value(data[key], keys[1:], new_value)

# Function to update hierarchical YAML in the file
def update_yaml_file(file_path, key_to_replace, new_value):
    with open(file_path, 'r') as yaml_file:
        data = yaml.safe_load(yaml_file)

    keys = key_to_replace.split('.')
    replace_yaml_value(data, keys, new_value)

    with open(file_path, 'w') as yaml_file:
        yaml.dump(data, yaml_file, default_flow_style=False, Dumper=yaml.Dumper)

if __name__ == '__main__':
    arguments = docopt(USAGE)

    file_path = arguments['<file_path>']
    key_to_replace = arguments['<key_to_replace>']
    new_value = arguments['<new_value>']

    update_yaml_file(file_path, key_to_replace, new_value)
