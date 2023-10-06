#!/usr/bin/env python
"""
Usage:
  sync_project.py [-h] [--username USERNAME] [--location LOCATION] [--hostname HOSTNAME] [--exclude EXTENSION]

Options:
  -h --help                  Show this help message and exit.
  --username USERNAME        Specify the username for SSH connection. [default: thf2bn]
  --location LOCATION        Specify the local directory where the remote directory should be synced.
  --hostname HOSTNAME        Specify the hostname or remote server address. [default: rivanna]
  --exclude EXTENSION        Specify file extensions to exclude from the download, separated by commas (e.g., --exclude .txt,.log)

Examples:
  ./sync_project.py --exclude .h5
"""

import os
import subprocess
from docopt import docopt
from pprint import pprint
from cloudmesh.common.util import banner

def sync_project(username, location, hostname, exclude_extensions):
    current_directory_basename = os.path.basename(os.getcwd())
    remote_directory = f"{username}@{hostname}:{location}"
    local_directory = "."

    # Construct the rsync command
    rsync_command = [
        "rsync",
        "-avz",  # Options for archive mode, verbose, and compression
    ]

    # Add --exclude flag only if exclude_extensions is defined
    if exclude_extensions:
        rsync_command.extend([f"--exclude={ext}" for ext in exclude_extensions])

    rsync_command.extend([remote_directory, local_directory])

    banner("COMMAND")
    print (" ".join(rsync_command))
    banner("TRANSFER")
    # Run the rsync command
    subprocess.call(rsync_command)

if __name__ == "__main__":
    arguments = docopt(__doc__)
    pprint(arguments)
    username = arguments["--username"] or "thf2bn"

    cwd = os.path.basename(os.getcwd())
    location = arguments["--location"] or f"/scratch/{username}/github/mlcommons/benchmarks/cloudmask/target/{cwd}/project"

    hostname = arguments["--hostname"] or "rivanna"

    exclude_extensions = arguments["--exclude"] or "*.h5"

    exclude_extensions = exclude_extensions.split(",")
    # exclude h5


    sync_project(username, location, hostname, exclude_extensions)


