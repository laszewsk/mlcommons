#! /usr/bin/env python
import os
from pathlib import Path

import yaml
from cloudmesh.common.util import banner
from cloudmesh.common.util import readfile
from cloudmesh.common.Shell import Shell
import glob

banner("CREATE NOTEBOOK COPIES")
config = yaml.safe_load(readfile("ubuntu-config.yaml"))

for experiment in glob.glob("project/*"):
    print (experiment)
    destination = experiment
    source = config["script"]
    source = str(Path(f'../../{source}').resolve())
    print (f"{source} -> {destination}")
    Shell.copy_file(source=source, destination=destination)