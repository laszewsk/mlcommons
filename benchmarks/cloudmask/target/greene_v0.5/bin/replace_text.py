#!/usr/bin/env python

import sys
from docopt import docopt

# Usage string for docopt
USAGE = """
Replace text in a file.

Usage:
  replace_text.py <file_path> <old_text> <new_text>
  replace_text.py -h | --help

Options:
  -h --help       Show this help message and exit.
"""

# Function to replace text in a file
def replace_text(file_path, old_text, new_text):
    try:
        with open(file_path, 'r') as file:
            content = file.read()

        content = content.replace(old_text, new_text)

        with open(file_path, 'w') as file:
            file.write(content)
        #print(f"Text '{old_text}' replaced with '{new_text}' in '{file_path}'.")

    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
        sys.exit(1)

if __name__ == '__main__':
    arguments = docopt(USAGE)

    file_path = arguments['<file_path>']
    old_text = arguments['<old_text>']
    new_text = arguments['<new_text>']

    replace_text(file_path, old_text, new_text)
