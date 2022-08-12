#! /usr/bin/env python
import os
from pathlib import Path

import yaml
from cloudmesh.common.util import banner
from cloudmesh.common.util import readfile
from cloudmesh.common.Shell import Shell
from cloudmesh.common.console import Console
from pprint import pprint

import sys
import glob

#
# GET YAML FILE NAME
#
configs = glob.glob("*.yaml")

if  len(sys.argv) == 1:
    Console.error("Please chose a yaml file as parameter or chose a number:")
    for i in range(0, len(configs)):
        print(f"{i}) {configs[i]}")
    print()
    sys.exit(0)

try:
    i = int(sys.argv[1])
    print (configs[i])
    filename = configs[i]
except:
    print ("B")
    filename = sys.argv[1]
print (filename)

if not os.path.exists(filename):
    Console.error(f"File {filename} not found")
    sys.exit(1)

banner(filename)

content = readfile(filename)
config = yaml.safe_load(content)

banner("GET DATA")

pprint (config["data"])

user = Shell.user()
home = os.environ["HOME"]

git = config["data"]["git"]
destination = config["data"]["destination"].format(user=user, home=home)

print (destination)
Shell.mkdir(destination)

repo_name = os.path.basename(git).replace(".git", "")

if not os.path.exists(f"{destination}/{repo_name}"):
     print ("* checkout")
     repo = config["data"]["git"]
     os.system(f"cd {destination}; git clone {repo}")
else:
    print("* pull")
    os.system(f"{destination}/{repo_name}; git pull")

banner("UNCOMPRESS")

if not os.path.exists(f"{destination}/{repo_name}/data/EarthquakeDec2020"):
    os.system(f"cd {destination}/{repo_name}; tar xvf data.tar.xz")
    Shell.mkdir(f"{destination}/{repo_name}/data/EarthquakeDec2020/Outputs")
else:
    print("* data already uncompressed")


