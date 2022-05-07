#!/usr/bin/env bash

#!/bin/bash

# Begin LSF Directives
#BSUB -P ABC12
#BSUB -W 3:00
#BSUB -nnodes 2048
#BSUB -alloc_flags gpumps
#BSUB -J RunSim123
#BSUB -o RunSim123.%J
#BSUB -e RunSim123.%J


# ... SBATCH --job-name=mlcommons-eq-{card_name}-{gpu_count}
# ... SBATCH --output=%u-%j.out
# ... SBATCH --error=%u-%j.err
# ... SBATCH --partition={system.partition}
# ... SBATCH -c {cpu_num}
# ... SBATCH --mem={mem}
# ... SBATCH --time={time}
# ... SBATCH --gres=gpu:{card_name}:{gpu_count}
# ... SBATCH --mail-user=%u@virginia.edu
# ... SBATCH --mail-type=ALL
# ... SBATCH --account={user.account}

set -uxe

### BEGIN CONFIGURATION

## Set the python version to target
PYTHON_VERSION={system.python}

## Specifies the git branch to use from the repository
## by default using {run.branch}
## The SAFE version cleans the name of any path-like characters
BRANCH=${BRANCH:-{run.branch}}
BRANCH_SAFE=${BRANCH/\//-}

## Specifies a github fork to use when running the build
FORK=${FORK:-"laszewsk"}

## Specifies the username to apply when running on a
## clustrered environment
RUN_USER=${USER:-unknown}

## Specifies the primary directory to use when running the
## benchmark.  When not specifies, it assumes the username
## on the sytem as the directory.
MLCOMMONS_HOME=${MLCOMMONS_HOME:-{run.workdir}/$RUN_USER}
RUN_BASE=${MLCOMMONS_HOME}/workspace
VENV_PATH=${MLCOMMONS_HOME}/venv-${PYTHON_VERSION}

## Specifies a specific revision of the Earthquake notebook
## Used to select the different folder names in the earthquake
## directory
REV="mar2022"

## Specifies a particular variant of the notebook to use
## if working on an alternate baseline.
VARIANT="${VARIANT:--gregor}"

## Specifies the path that contains utilities on the HPC
## cluster, such as the system scripts.
RESOURCE_DIR="{run.resource_dir}"


### END CONFIGURATION

# Cleanup locks and temporary files on failed execution
trap "rm -f ${VENV_PATH}.lock ${MLCOMMONS_HOME}/mlcommons.lock; exit" 1 2 3 6 15


### FUNCTION BEGIN
# Performs a git checkout
# GLOBALS:
#   MLCOMMONS_HOME
#   GIT_REV
# ARGUMENTS:
#   $1 - The url to use with the git command
#   $2 - The folder to place the cloned repo into
#   $3 - The branch to checkout after cloning.  By default, this is "main".
# OUTPUTS:
#   Git command line output
### FUNCTION END
function git_checkout() {
    local repo_url=$1
    local target=$2
    local branch=${3:-main}

    repo_folder=$(basename ${repo_url} .git)

    # Clone the repo if it doesn't already exist and switch to the
    # targeted branch.
    if [ ! -e "${MLCOMMONS_HOME}/${repo_folder}" ]; then
        git clone $repo_url "${MLCOMMONS_HOME}/${repo_folder}"
        (cd ${MLCOMMONS_HOME}/${repo_folder} && \
            git checkout $branch)
    # Ensure that the current checkout doesn't have any local edits
    # and checks out the named branch.
    else
        (cd ${MLCOMMONS_HOME}/${repo_folder} && \
            git fetch origin  && \
            git checkout $branch && \
            git reset --hard origin/$branch && \
            git clean -d --force)
    fi
    GIT_REV="$(cd "${MLCOMMONS_HOME}/${repo_folder}" && git rev-parse --short=8 HEAD)"
}


### FUNCTION BEGIN
# Creates a file lock handle.  Creates an empty file in
# $MLCOMMONS_HOME with the passed name as a dot file.
# GLOBALS:
#   MLCOMMONS_HOME
# ARGUMENTS:
#   $1 - The lock name to register in MLCOMMONS_HOME
### FUNCTION END
function make_lock() {
    local lockname="${MLCOMMONS_HOME}/.$1"
    touch "${lockname}"
}

### FUNCTION BEGIN
# Releases a file lock handle.  Deletes an empty file in
# $MLCOMMONS_HOME with the passed name as a dot file.
# GLOBALS:
#   MLCOMMONS_HOME
# ARGUMENTS:
#   $1 - The lock name to register in MLCOMMONS_HOME
### FUNCTION END
function release_lock() {
    local lockname="${MLCOMMONS_HOME}/.$1"
    rm "${lockname}"
}

### FUNCTION BEGIN
# Deadwait function that stops execution while the named
# lock is present on the filesystem.
# GLOBALS:
#   MLCOMMONS_HOME
# ARGUMENTS:
#   $1 - The lock name to register in MLCOMMONS_HOME
#   $2 - The duration to wait in seconds.  Defaults to 5 seconds.
# OUTPUTS:
#   Prints a dot every increment that the file lock is present.
### FUNCTION END
function wait_lock() {
    local lockname="${MLCOMMONS_HOME}/.$1"
    local delay=${2:-5}
    printf "Checking for lock ${lockname}"
    while [ -e ${lockname}.lock ] ; do
      printf "."
      sleep $delay
    done
    printf ". Done\n"
}

### FUNCTION BEGIN
# Utility function that waits until the named lock has been released
# and then immediately claims the lock.
# CALLTREE:
#   wait_lock
#   make_lock
# ARGUMENTS:
#   $1 - The lock name to use for wait_lock and make_lock
#   $2 - The duration to wait in seconds.  Defaults to 5 seconds.
# OUTPUTS:
#   Prints a dot every increment that the file lock is present.
### FUNCTION END
function waitmake_lock() {
    wait_lock $1 ${2:-5}
    make_lock $1
}


### FUNCTION BEGIN
# Outputs the total runtime accoring to the script.  Only functions
# when running on a slurm system
# GLOBALS
#   SLURM_JOBID
# OUTPUTS
#   a CSV prefixed with '# slurmjob,' with the jobid, username, submittion time
#   start time, end time, and status.
### FUNCTION END
function slurm_runtime() {
    # Run only if done in a slurm job
    if [[ ! -z "${SLURM_JOBID}" ]] ; then
      # Query current job details and substitute end time with the current time.
      sacct -j ${SLURM_JOBID} -P --delimiter=, -o jobid,user,submit,start,end,state \
        | sed -e 's/^/# slurmjob,/g' \
              -e 's/,Unknown,RUNNING$/,'$(date +%Y-%m-%dT%H:%m:%S -d @${END_TIME})'DONE/g'
    fi
}

### FUNCTION BEGIN
# Creates a virtual environment in a specified directory using a
# specific requirements.txt file.
# GLOBALS
#   RUN_BASE
# CALLTREE
#   waitmake_lock
# ARGUMENTS
#   $1 - The folder to establish the python virtual environment into
#   $2 - The path to a python requirements.txt file
### FUNCTION END
function setup_venv(){
    local target=$1
    local requirements_path=$2
    # Prevent parallel updates to pip
    waitmake_lock pip.lock
        python -m venv --upgrade-deps ${target}
	case "$(uname -s)" in
	  MINGW*) source ${target}/Scripts/activate ;;
	  *) source ${target}/bin/activate ;;
        esac
        python -m pip install -r ${requirements_path} \
            --progress-bar off
        python -m pip freeze > ${RUN_BASE}/pip-freeze.txt
    release_lock pip.lock
}

### FUNCTION BEGIN
# Outputs slurm-aware environment variables
# OUTPUT
#   A fenced listing of all current environment variables
#   beginning with SLURM_.  This is only displayed if the
#   current environment has the sbatch command installed.
### FUNCTION END
function slurm_env() {
  if command -v sbatch ; then
    echo "Slurm Environment Details"
    echo "===start[env]==========="
    printenv | grep "SLURM_"
    echo "===end[env]============="
  fi
}


mkdir -p ${RUN_BASE}
RUN_BASE_ABS=$(realpath ${RUN_BASE})

echo "Working in <$(pwd)>"
echo "Base directory in <${RUN_BASE}>"
echo "MLCommons home in <${MLCOMMONS_HOME}>"
echo "Revision: <${REV}>"
echo "Variant: <${VARIANT}>"
echo "Python: <${PYTHON_VERSION}>"
#echo "GPU: <${GPU_TYPE}>"




# Load cuda/python on HPCs if module is present.
if command -v module ; then
  module purge
  module use ${RESOURCE_DIR}/modulefiles
  # BUG need to reconfigure script to support python on other platforms.
  module load python-rivanna/${PYTHON_VERSION} cuda cudnn
fi

# Checkout git repo for mlcommons earthquake data, locking the repo
# to prevent concurrent git operations 
waitmake_lock mlcommons-data-earthquake.git
    git_checkout https://github.com/laszewsk/mlcommons-data-earthquake.git \
                 "${MLCOMMONS_HOME}/mlcommons-data-earthquake" \
                 main
release_lock mlcommons-data-earthquake.git

# Checkout git repo for mlcommons main repository, locking the repo
# to prevent concurrent git operations 
waitmake_lock mlcommons.git
    git_checkout https://github.com/laszewsk/mlcommons.git \
                 "${MLCOMMONS_HOME}/mlcommons" \
                 $BRANCH
    # Extract the mlcommons eearthquake data to the required path.
    if [ ! -e data/EarthquakeDec2020 ]; then
        tar Jxvf ${MLCOMMONS_HOME}/mlcommons-data-earthquake/data.tar.xz
        # BUG; should be in zip file (or created as part of the python file
        mkdir -p ${RUN_BASE}/data/EarthquakeDec2020/Outputs
    fi

    # Create a python virtual environment based on the current benchmark's requirements.txt file
    setup_venv ${VENV_PATH} \
               ${MLCOMMONS_HOME}/mlcommons/benchmarks/earthquake/${REV}/requirements.txt

    # Copy the earthquake notebook into our working directory to prevent any modifications to the git repo.
    mkdir -p notebooks
    cp ${MLCOMMONS_HOME}/mlcommons/benchmarks/earthquake/${REV}/FFFFWNPFEARTHQ_newTFTv29${VARIANT}.ipynb \
       FFFFWNPFEARTHQ_newTFTv29-$USER-${GIT_REV}.ipynb
release_lock mlcommons.git

# Execute the notebook usign papermill
papermill "FFFFWNPFEARTHQ_newTFTv29-${RUN_USER}-${GIT_REV}.ipynb" \
          "FFFFWNPFEARTHQ_newTFTv29-${RUN_USER}-${GIT_REV}_output.ipynb" \
          --no-progress-bar --log-output --log-level INFO

slurm_runtime
