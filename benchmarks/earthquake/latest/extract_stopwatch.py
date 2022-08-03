#!/usr/bin/python

"""
Trivial log collector of experement executions on managed jobs.

This program scans the current working directory for log messages that match
a specific pattern and extracts the cloudmesh timer logs that are prefixed with
the `# csv,` marking.  This program behaves similar to a recursive fgrep where
each folder gets its own output from running `fgrep '# csv,' path/to/log.err`.  
"""

import os
import pathlib
import re
import sys


cloudmesh_stopwatch_prefix = "# csv,"
filematch = ".err"


def main(argv):
    base_dir = "." if len(argv) < 2 else argv[1]

    for root, dirs, files in os.walk(base_dir):
        matches = [filename for filename in files if filematch in filename]
        for match in matches:
            with open(pathlib.Path(root)/match, 'rb') as f:
                with open(f"{root}-{match}_stopwatch.log", 'ab') as fout:
                    for line in f:
                        if re.search(cloudmesh_stopwatch_prefix, line.decode("utf-8")):
                            fout.write(line)

if __name__ == "__main__":
    main(sys.argv)
