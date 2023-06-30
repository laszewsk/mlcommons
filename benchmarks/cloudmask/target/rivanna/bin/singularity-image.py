#! /usr/bin/env python

import os
import sys
from cloudmesh.common.Shell import Shell
from cloudmesh.common.StopWatch import StopWatch
from cloudmesh.common.sudo import Sudo
from cloudmesh.common.util import banner

NAME = sys.argv[1]
home = os.environ["USER"]

banner ("SETUP")

hostname = Shell.run("hostname -a")
rivanna = "hpc.virginia.edu" in hostname

if not rivanna: 
    Sudo.password()

# CHECK FOR RIVANNA


singularity = "singularity"
if rivanna:
    singularity_cache = os.environ['SINGULARITY_CACHEDIR'] = f"/scratch/{home}/.singularity/cache"
    singularity = "/opt/singularity/3.7.1/bin/singularity"
else:
    singularity_cache = os.environ['SINGULARITY_CACHEDIR'] = f"{home}/.singularity/cache"
    singularity = "singularity"



print("NAME:                  ", NAME)
print("input def:             ", f"{NAME}.def")
print("output sif:            ", f"{NAME}.sif")

print("HOME:                  ", home)
print("singularity executable:", singularity)
print("singularity cache:     ", singularity_cache)



banner("RUN")

Shell.mkdir(singularity_cache)

StopWatch.start("total")


if rivanna:
    StopWatch.start("prepare build.def")
    Shell.copy(source=f"{NAME}.def", destination="build.def")
    StopWatch.stop("prepare build.def")

    command = f"sudo {singularity} build output_image.sif build.def"

else:
    command = f"sudo {singularity} build {NAME}.sif {NAME}.def"

banner (command)
StopWatch.start("image build")
os.system(command)
StopWatch.stop("image build")

if rivanna:
    StopWatch.start(f"write {NAME}.sif")
    Shell.copy(source="output_image.sif",  destination=f"{NAME}.sif")
    StopWatch.stop(f"write {NAME}.sif")

banner("SIZE")

size = Shell.run(f"du -sh {NAME}.sif")

print (size)
StopWatch.event("size cloudmesh.sif",msg=size.split()[0])

# make -f Makefile clean
StopWatch.stop("total")

StopWatch.benchmark()


