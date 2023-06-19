#! #!/usr/bin/env python

from cloudmehs.common.util import banner
from cloudmehs.common.Shell import Shell
from cloudmehs.common.StopWatch import StopWatch

import os

AWS_S3="aws s3 --no-sign-request --endpoint-url https://s3.echo.stfc.ac.uk"

try:
  PROJECT_DATA = os.environ["PROJECT_DATA"]
except Exception as e:
  print (e)
  exit(1)

try:
  PROJECT_DIR = os.environ["PROJECT_DIR"]
except Exception as e:
  print (e)
  exit(1)

 
StopWatch.start("create data dirs")
Shell.mkdir(f"{PROJECT_DATA}/ssts")
Shell.mkdir("f{PROJECT_DATA}/one-day")
StopWatch.stop("create data dirs")


banner ("Downloading first portion of data")
StopWatch.start("download one-day data")
os.system("cd $(PROJECT_DIR); $(AWS_S3) sync s3://sciml-datasets/es/cloud_slstr_ds1/one-day ./data/one-day --cli-read-timeout 0")
StopWatch.stop("one-day data")

banner"Downloading second portion of data")
StopWatch.start("download ssts data")
os.system("cd $(PROJECT_DIR); $(AWS_S3) sync s3://sciml-datasets/es/cloud_slstr_ds1/ssts ./data/ssts --cli-read-timeout 0")
StopWatch.start("download ssts data")

StopWath.benchmark()
