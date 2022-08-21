#! /usr/bin/env python
import glob
import os
from pathlib import Path
from pprint import pprint
import subprocess
import sys
import tarfile
import yaml

import eq_lib

from cloudmesh.common.util import banner
from cloudmesh.common.util import readfile
from cloudmesh.common.Shell import Shell
from cloudmesh.common.console import Console
import tqdm


#
# GET YAML FILE NAME
#


def main(argv, ext="yaml"):
    filename = eq_lib.get_config(argv, ext)

    # banner(filename)

    content = readfile(filename)
    config = yaml.safe_load(content)

    # banner("GET DATA")
    pprint (config["data"])

    git = config["data"]["git"]

    destination = eq_lib.expand_string(config["data"]["destination"])
    # print(destination)
    Shell.mkdir(destination)

    repo_name = os.path.basename(git).replace(".git", "")

    if not os.path.exists(f"{destination}/{repo_name}"):
         print ("* checkout")
         repo = config["data"]["git"]
         subprocess.check_call(['git', 'clone', repo], cwd=f"{destination}")
         print("\\ Complete")
    else:
        print("* pull")
        subprocess.check_call(["git", "pull"], cwd=f"{destination}/{repo_name}")

    # banner("UNCOMPRESS")
    if not os.path.exists(f"{destination}/{repo_name}/data/EarthquakeDec2020"):
        with tarfile.open(f"{destination}/{repo_name}/data.tar.xz", 'r') as tf:
            print(f"Extracting {tf.name}")
            for member in tqdm.tqdm(iterable=tf.getmembers(), total=len(tf.getmembers())):
                # Extract member
                tf.extract(member=member, path=f"{destination}/{repo_name}")
    else:
        print("* data already uncompressed")


if __name__ == '__main__':
    main(argv=sys.argv)

