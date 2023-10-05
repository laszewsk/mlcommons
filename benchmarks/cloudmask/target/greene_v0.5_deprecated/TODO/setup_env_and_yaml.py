#!/usr/bin/env python
# from cloudmesh.common.Shell import Shell
# from cloudmesh.common.Shell import Console
import sys
import os

try:
    env = sys.argv[1]
    version = sys.argv[2]
except:
    env = "cloudenv"
    version = "3.10.8"

"""
conda env list
# conda environments:
#
ENV3                     /ccs/home/gregor/.conda/envs/ENV3
ENV4                     /ccs/home/gregor/.conda/envs/ENV4
bench                    /ccs/home/gregor/.conda/envs/bench
cylon_dev2               /ccs/home/gregor/.conda/envs/cylon_dev2
base                  *  /sw/summit/python/3.8/anaconda3/2020.07-rhel8

$ conda env list
-bash: conda: command not found
"""

# username = Shell.user()
username = os.popen('whoami').read().strip()
print(f"sed -i 's/USERTOREPLACE/{username}/g' config.yaml")
os.system(f"sed -i 's/USERTOREPLACE/{username}/g' config.yaml")

"""

if "command not found" in os.popen("conda env list").read():
    try:
        print("conda module not yet loaded")
        os.system("module load anaconda")
    except Exception as e:
        print(e.output)
"""
#if env in os.popen("conda env list").read():
#    print(f"environment {env} already installed in conda")
#else:
#    os.system(f"conda create -f -y -n {env} -c conda-forge python={version}")

# nvidia-smi --list-gpus
