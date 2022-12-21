# Running on Rivanna Using the Simple Configuration

## Set up experiment utilities

Tip: use option 1

1. Load in Python 3.10
   1. Option 1 - Using Anaconda
      ```bash
      module purge
      module load anaconda

      conda create -y -n py3.10 python=3.10
      source activate py3.10
      ```
   
   2. Option 2 - Using Native Python with custom build python.
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

The last line can also be with `--ssh` if you use ssh instead of http for 
git checkouts. Note that if you elect to use the ssh configuration, you 
may be frequently prompted for your password. You can cache your password 
by establishing an ssh-agent prior to running the command by running:

```bash
eval `ssh-agent -s`
ssh-add
cloudmesh-installer --ssh get sbatch
cms help
```
## Preparing Earthquake Environment from the Production Code

1. Generating experiment configurations

   Choose a PROJECT_DIR where you like to install the code. Rivanna offers some temporary
   space in the /scratch directory. 

   ```bash
   export PROJECT_DIR=/scratch/$USER
   mkdir -p $PROJECT_DIR
   cd $PROJECT_DIR
   export EQ_VERSION=latest

   # FOR USERS
   git clone https://github.com/mlcommons/science.git
   cd science
   git checkout main
   cd $PROJECT_DIR/science/benchmarks/earthquake/$EQ_VERSION/experiments/rivanna
   ```

## Preparing Earthquake Environment from the Development Code

Skip this step if you run the production version.

1. Generating experiment configurations

   ```bash
   export PROJECT_DIR=/scratch/$USER
   mkdir -p $PROJECT_DIR
   cd $PROJECT_DIR
   export EQ_VERSION=latest
   
   git clone ssh://git@github.com/laszewsk/mlcommons.git
   cd $PROJECT_DIR/mlcommons/benchmarks/earthquake/$EQ_VERSION/experiments/rivanna
   git checkout main
   ```

## Run a particular configuration

2. Set your desired configuration you wish to run:

   ```bash
   # One of - localscratch, project, shm, dgx, or dgx-shm
   export EQ_CONFIGURATION="localscratch"
   ```
3. Optionally remove previous generated setup

   ```bash
   rm -rf $EQ_CONFIGURATION
   rm $EQ_CONFIGURATION.json
   rm jobs-$EQ_CONFIGURATION.sh
   ```

5. Perform a 1 time bootstrap of your environment.

   ```bash
   make setup-$EQ_CONFIGURATION
   ## or run the following
   # python 01-fetch-data.py rivanna-$EQ_CONFIGURATION.yaml
   # python 02-setup-venv.py rivanna-$EQ_CONFIGURATION.yaml 
   ```


## Generating Experiment Permutations

### Selecting a Configurations

This procedure is preconfigured for running the benchmark on Rivanna using the
`/localscratch` filesystem, however there are alternate configurations that may
be targeted after the above bootstrapping has been performed.
These include:

* `localscratch` - uses rivanna's local NVMe filesystem
* `project` - uses Rivanna's special `/project` network file system
* `shm` - uses the `/dev/shm` device for in-memory filesystem processing.
* `dgx` - uses Rivanna's DGX workstation.
* `dgx-shm` - uses Rivanna's DGX workstation leveraging the `/dev/shm` directory for in-memory filesystem processing.

To change your configuration, run the following:

```bash
# One of - localscratch, project, shm, dgx, or dgx-shm
export EQ_CONFIGURATION="localscratch"
```


### Finding your Allocation

To find out which allocations are avalable to you use the command

```bash
allocations
```
it will show the allocations table which looks similar to 

```
Account                      Balance        Reserved       Available                
-----------------          ---------       ---------       ---------                
bii_dsc                       100000               0         98565.3                
bii_dsc_community             100000               0         99998.8                
bii_nssac                     500000               0        352387                
biocomplexity                 100000               0         30773.4                
ds6011-sp22-002               100000               0         59156.2   
```

Choose the allocation which is most appropriate for you and change it 
in its corresponding yaml file (e.g. for localscratch, the yaml is called
`rivanna-localscratch.yaml`). Locate the following line and change accordingly.

### Using a V100 on rivanna 

To use a v100 you have to set the following.
The bi_fox_dgx reservation does not have a v100 
and will fail if one is requested on that reservation.

```yaml
experiment:
  card_name: v100

run:
  allocation: bii_dsc_community 

system:
  partition: gpu
```


### Using an a100 (new) on rivanna 

To use an a100 you have to set the following.

Please note that only bii_dsc_community, bii_dsc are able to use a new 
version of the A100 if the following are included in the yaml file.


```yaml
system:
  partition: bii-gpu

run:
  allocation: bii_dsc
  reservation: bi_fox_dgx
```

### Generating Active Configuration

1. Generate your configuration's scripts
   ```bash
   make generate-$EQ_CONFIGURATION
   ```

It is strongly advised that you inspect the output of the above to validate 
that all generated scripts and files are correct. Most jobs take several 
hours, so correcting errors by inspecting the output will save time when 
troubleshooting.

**IMPORTANT**
On Rivanna, when using the `/project`or `/scratch` filesystems, there is a 
file limit quota that will terminate your job immediately if you exceed it.
Make sure that you do not run more than 5 jobs concurrently in the `project` 
configuration.

You will be able to see the generated scripts with the coommand

```bash
ls -1 $EQ_CONFIGURATION
```

```
card_name_v100_gpu_count_1_cpu_num_6_mem_32GB_repeat_1_TFTTransformerepochs_10
card_name_v100_gpu_count_1_cpu_num_6_mem_32GB_repeat_1_TFTTransformerepochs_2
card_name_v100_gpu_count_1_cpu_num_6_mem_32GB_repeat_1_TFTTransformerepochs_20
card_name_v100_gpu_count_1_cpu_num_6_mem_32GB_repeat_1_TFTTransformerepochs_30
card_name_v100_gpu_count_1_cpu_num_6_mem_32GB_repeat_1_TFTTransformerepochs_34
card_name_v100_gpu_count_1_cpu_num_6_mem_32GB_repeat_1_TFTTransformerepochs_40
card_name_v100_gpu_count_1_cpu_num_6_mem_32GB_repeat_1_TFTTransformerepochs_50
card_name_v100_gpu_count_1_cpu_num_6_mem_32GB_repeat_1_TFTTransformerepochs_60
card_name_v100_gpu_count_1_cpu_num_6_mem_32GB_repeat_1_TFTTransformerepochs_70
```

To modify them, please make changes to the experiments that you run, 
please edit the file rivanna-$EQ_CONFIGURATION.yaml

```bash
emacs rivanna-$EQ_CONFIGURATION.yaml
```

Before running the experiments check if they are ok, as it can take a very 
long time to run them on Rivanna dependent on the GPU used 
(2epoch run on A100 ~4 hours and for K80 it runs 24 hours).

(Right now v100 is the default)

### Running the Experiments

If the output from the cloudmesh sbatch command matches your experiment's 
configuration, then the experiment is ready to be executed on Rivanna using

```bash
sh jobs-$EQ_CONFIGURATION.sh
```

This will request all jobs to be run immediately by slurm, and the notebook file will be outputted in:

* Project: `$(pwd)/project/<experiment_id>`
* Localscratch: `$(pwd)/localscratch/<experiment_id>`
* SHM: `$(pwd)/shm/<experiment_id>`
* DGX: `$(pwd)/dgx/<experiment_id>`

You can see the progress of each job by inspecting the `*.out` and `*.err` files located in any of the aforementioned output folders.
A useful command is to run `tail -f $USER-*.err $USER-*.out`, which will watch the progress of both logs.  You can exit this command by pressing `ctrl+c`.

A copy of the final notebook is placed in the slurm experiments folder with the suffix `*_output.ipynb`, that can be inspected for further details.

### Single test experiment

To only run a single experiment to see if things work, we recommand you run the commands

```
head -n 1 jobs-$EQ_CONFIGURATION.sh > test_run.sh
sh test_run.sh 
```

## Monitor the job

use the slurm commands

```
squeue -u $USER
```

```
localscratch/*_2/*.err
localscratch/*_2/*.out
```

## Rerun after changes

```
emacs rivanna-$EQ_CONFIGURATION.yaml
make clean
make generate-$EQ_CONFIGURATION
head -n 1 jobs-$EQ_CONFIGURATION.sh > test_run.sh
cat test_run.sh
sh test_run.sh 
squeue -u $USER
```
