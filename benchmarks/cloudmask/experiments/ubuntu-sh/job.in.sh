#!/usr/bin/env bash

echo "# cloudmesh status=running progress=1 pid=$$"


WORKDIR=/project1

set -uxe

RUN_BASE="{run.filesystem}/mlcommons/{experiment.epoch}/{experiment.repeat}"
DATA_PATH="/$WORKDIR/${USER}/mlcommons/benchmarks/cloudmask/data"

THEPATH=$(realpath $0)

echo "# cloudmesh status=running progress=2 pid=$$"

# ####################################################################################################
# CLOUDMASK
# ####################################################################################################

echo "# cloudmesh status=running progress=5 pid=$$"

echo "Working in Directory:      $(pwd)"
echo "Running in Directory:      ${RUN_BASE}"
echo "Experiment Data Directory: ${DATA_PATH}"
echo "Repository Revision:       $(git rev-parse HEAD)"
echo "Notebook Script:           {code.script}"
echo "Python Version:            $(python -V)"
echo "Running on host:           $(hostname -a)"


# sed -i "/log_file:/c\log_file: $(dirname $THEPATH)/cloudmask_run.log" $(dirname $THEPATH)/config.yaml
# sed -i "/mlperf_logfile:/c\mlperf_logfile: $(dirname $THEPATH)/mlperf_cloudmask.log" $(dirname $THEPATH)/config.yaml
# sed -i "/model_file:/c\model_file: $(dirname $THEPATH)/cloudModel.h5" $(dirname $THEPATH)/config.yaml


echo "# cloudmesh status=running progress=6 pid=$$"

cd /$WORKDIR/$USER/mlcommons/benchmarks/cloudmask/experiments

cms gpu watch --gpu=0 --delay=1 --dense > $(dirname $THEPATH)/gpu0.log &

python -m ubuntu-sh.slstr_cloud --config $(dirname $THEPATH)/config.yaml > $(dirname $THEPATH)/output.log 2>&1

# python slstr_cloud.py --config $(dirname $THEPATH)/config.yaml > $(dirname $THEPATH)/output.log 2>&1

echo "# cloudmesh status=done progress=100 pid=$$"

echo "Execution Complete"

#
exit 0

