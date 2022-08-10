#!/usr/bin/env bash

set -uxe

cms banner "BEGIN CONFIGURATION"
cms progress 1 --banner --now

### BEGIN CONFIGURATION

## Specifies the path to save the final output
NB_OUTPUT="_output"

## Unique identifier to isolate executions from each other.
RUN_ID="${RUN_ID:-{meta.uuid}}"

## Specifies the primary directory to use when running the
## benchmark.  When not specifies, it assumes the username
## on the sytem as the directory.
MLCOMMONS_HOME=${MLCOMMONS_HOME:-{run.workdir}}

## Specifies a specific revision of the Earthquake notebook
## Used to select the different folder names in the earthquake
## directory
REV="{revision}"

### END CONFIGURATION


cms banner "GENERAL SETUP OF FUNCTIONS"
cms progress 2 --banner --now


## Specifies the username to apply when running on a
## clustrered environment
RUN_USER=`whoami`

## Sets up the base directory for running the experiment from the
## previously defined vars.
RUN_BASE=${MLCOMMONS_HOME}/${RUN_USER}/workspace-${RUN_ID}
GIT_BASEPATH=${HOME}


###############################################################################
mkdir -p ${RUN_BASE}
RUN_BASE_ABS=$(realpath ${RUN_BASE})
###############################################################################


###############################################################################
# INFO
cms banner INFO
# ===========================================================================--

echo "Working in <$(pwd)>"
echo "Base directory in <${RUN_BASE}>"
echo "MLCommons home in <${MLCOMMONS_HOME}>"
echo "Revision: <${REV}>"
echo "Script: <{script}>"
echo "Python: <${PYTHON_VERSION}>"
echo "Run ID: <${RUN_ID}>"

if [ -e "$(pwd)/config.yaml" ]; then
	cp $(pwd)/config.yaml ${RUN_BASE_ABS}
fi


###############################################################################
cms banner "Extract the mlcommons earthquake data"
# -----------------------------------------------------------------------------

if [ ! -e ${RUN_BASE}/data/EarthquakeDec2020 ]; then
        tar Jxvf ${GIT_BASEPATH}/mlcommons-data-earthquake/data.tar.xz \
            -C ${RUN_BASE}
        # BUG; should be in zip file (or created as part of the python file
        mkdir -p ${RUN_BASE}/data/EarthquakeDec2020/Outputs

fi

###############################################################################
cms banner "copy notebook"
# -----------------------------------------------------------------------------

# Copy the earthquake notebook into our working directory to prevent any modifications to the git repo.
mkdir -p ${NB_OUTPUT}
cp ${GIT_BASEPATH}/mlcommons/benchmarks/earthquake/${REV}/{script} \
       ${RUN_BASE}/FFFFWNPFEARTHQ_newTFTv29-${RUN_USER}.ipynb


###############################################################################
cms banner "GIT CHECKOUT COMPLETED"
cms progress 9 --banner --now
###############################################################################


###############################################################################
cms banner "RUN NOTEBOOK IN PAPERMILL"
cms progress 10 --banner --now
# =============================================================================

# Execute the notebook using papermill
papermill "${RUN_BASE}/FFFFWNPFEARTHQ_newTFTv29-${RUN_USER}.ipynb" \
          "${RUN_BASE}/FFFFWNPFEARTHQ_newTFTv29-${RUN_USER}_output.ipynb" \
          --no-progress-bar --log-output --log-level INFO

cms progress 90 --banner --now
###############################################################################

cms bannner "SAVE OUTPUT"

# Save the final notebook after everything's done
echo "Saving final notebook to ${NB_OUTPUT}"
cp "${RUN_BASE}/FFFFWNPFEARTHQ_newTFTv29-${RUN_USER}_output.ipynb" \
   "${NB_OUTPUT}/FFFFWNPFEARTHQ_newTFTv29_output.ipynb"

echo "Saving graphical outputs to ${NB_OUTPUT}/gfx"
mkdir -p ${NB_OUTPUT}
cp -R "${RUN_BASE}/data/EarthquakeDec2020/Outputs" ${NB_OUTPUT}

echo "Execution Complete"

###############################################################################
cms banner "EXECUTION DONE"
cms progress 100 --banner --now
###############################################################################

exit 0
