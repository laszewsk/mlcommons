# Running on Rivanna Using the Simple Configuration

## Set up experiment utilities

1. Load in Python 3.10
   1. Option 1 - Using Anaconda
      ```bash
      module purge
      module load anaconda

      conda create -y -n py3.10 python=3.10
      source activate py3.10
      ```
   2. Option 2 - Using Native Python
      ```bash
      module purge
      module use /project/bii_dsc/mlcommons-system/modulefiles
      module load python-rivanna
      ```
      Note: This module uses a custom version of python as configured in [Building Python](https://github.com/laszewsk/mlcommons/tree/main/systems/rivanna/buildscripts/python-rivanna) and loading the lua modules in a preconfigured directory setup at [Configuring Python](https://github.com/laszewsk/mlcommons/tree/main/systems/rivanna/modulefiles/python-rivanna).  Details on how to add to these files can be found in the [systems](https://github.com/laszewsk/mlcommons/tree/main/systems/rivanna) folder.

2. Setup Cloudmesh and the cloudmesh sbatch utility.
   ```bash
   python3.10 -m venv ~/ENV3
   source ~/ENV3/bin/activate
   which python
   python -V
   mkdir ~/cm
   cd ~/cm
   pip install pip -U
   pip install cloudmesh-installer
   cloudmesh-installer get sbatch
   cms help
   ```

The last line can also be with `--ssh` if you sue ssh instead of http for git checkouts.
Note that if you elect to use the ssh configuration, you may be frequently prompted for your password.  You can cache your password by establishing an ssh-agent prior to running the command by running:

```bash
eval `ssh-agent -s`
ssh-add
cloudmesh-installer --ssh get sbatch
```

## Preparing Earthquake Environment

1. Generating experiment configurations
   ```bash
   cd ~
   export EQ_VERSION=latest

   # FOR USERS
   git clone https://github.com/laszewsk/mlcommons.git
   # Or for developers
   # git clone git@github.com:laszewsk/mlcommons.git
   cd ~/mlcommons/benchmarks/earthquake/$EQ_VERSION/experiments/rivanna-simple
   ```
   
2. Set your desired configuration you wish to run:
   ```bash
   # One of - localscratch, project, shm, dgx, or dgx-shm
   CONFIGURATION="localscratch"
   ```

3. Perform a 1 time bootstrap of your environment.
   ```bash
   make setup-$CONFIGURATION
   ## or run the following
   # python 01-fetch-data.py rivanna-$CONFIGURATION.yaml
   # python 02-setup-venv.py rivanna-$CONFIGURATION.yaml 
   ```

## Generating Experiment Permutations

1. Generate your configuration's scripts
   ```bash
   make generate-$CONFIGURATION
   ```

It's strongly advised that you inspect the output of the above to validate that all generated scripts and files are correct.
Most jobs take several hours, so correcting errors by inspecting the output will save time when troubleshooting.

**IMPORTANT**
On Rivanna, when using the `/project`or `/scratch` filesystems, there is a file limit quota that will terminate your job immediately if you exceed it.
Make sure that you do not run more than 5 jobs concurrently in the `project` configuration.

### Running the Experiments

If the output from the cloudmesh sbatch command matches your experiment's configuration, then the experiment is ready to be executed on rivanna using

```bash
sh job-$CONFIGURATION.sh
```

This will request all jobs to be run immediately by slurm, and the notebook file will be outputted in:

* Project: `$(pwd)/project/<experiment_id>`
* Localscratch: `$(pwd)/localscratch/<experiment_id>`
* SHM: `$(pwd)/shm/<experiment_id>`
* DGX: `$(pwd)/dgx/<experiment_id>`

You can see the progress of each job by inspecting the `*.out` and `*.err` files located in any of the aforementioned output folders.
A useful command is to run `tail -f $USER-*.err $USER-*.out`, which will watch the progress of both logs.  You can exit this command by pressing `ctrl+c`.

A copy of the final notebook is placed in the slurm experiments folder with the suffix `*_output.ipynb`, that can be inspected for further details.
