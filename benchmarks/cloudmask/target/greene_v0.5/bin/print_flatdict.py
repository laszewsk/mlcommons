#!/usr/bin/env python

"""
Read and print a YAML file using cloudmesh-common's FlatDict.

Usage:
  print_flatdict.py <file_path>
  print_flatdict.py -h | --help

Options:
  -h --help      Show this help message and exit.
"""

import sys
from docopt import docopt
from cloudmesh.common.FlatDict import FlatDict

def read_and_print_yaml(file_path):
    try:

        data = FlatDict()
        data.load(content=file_path)
        for key in data:
            print (f"{key}:", data[key])
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
        sys.exit(1)

if __name__ == '__main__':
    arguments = docopt(__doc__)

    file_path = arguments['<file_path>']

    read_and_print_yaml(file_path)
