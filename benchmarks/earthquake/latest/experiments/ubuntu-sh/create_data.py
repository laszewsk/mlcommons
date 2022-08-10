#! /usr/bin/env python
import os
from pathlib import Path

import yaml
from cloudmesh.common.util import banner
from cloudmesh.common.util import readfile

content = readfile("ubuntu-config.yaml")

config = yaml.safe_load(content)

banner("GET DATA")
data_dir = str(Path("./mlcommons-data-earthquake").resolve())

if not os.path.exists(data_dir):
    print ("* checkout")
    repo = config["data"]["git"]
    os.system(f"git clone {repo}")
else:
    print("* pull")
    os.system(f"cd {data_dir}; git pull")

banner("UNCOMPRESS")

if not os.path.exists(f"./{data_dir}/data/EarthquakeDec2020"):
    os.system(f"cd {data_dir}; tar xvf data.tar.xz")
    os.system(f"mkdir -p ./{data_dir}/data/EarthquakeDec2020/Outputs")
else:
    print("* data already uncompressed")
