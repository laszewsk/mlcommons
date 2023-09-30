# All-Encompassing Guide on <mark>greene_v0.5/</mark> Directory (GRC version)

## Nomenclature
* [PROJ_DIR] := ~/mlcommons/benchmarks/cloudmask/target/greene_v0.5/
* [OLD_PROJ_DIR] := ~/mlcommons/benchmarks/cloudmask/target/greene/

## Main Changes from greene/ Directory (NYU version)
1. Implemented Singularity with Miniconda Overlay
2. Improved reproduce_experiments.sh to GRCtest_reproduce_experiments.sh
3. Added early stopping feature
4. Added helper bash scripts (clean_outputs.sh, archive_outputs.sh)
5. Improved visualizer.py, changed format to .ipynb, created leaderboard for experiment analysis (incomplete)


## 1. Singularity with Miniconda Overlay
There is a more detailed, official documentation of running [Singularity on Greene](https://sites.google.com/nyu.edu/nyu-hpc/hpc-systems/greene/software/singularity-with-miniconda?authuser=0). But the following guide should suffice.

* Let's start, cd into [PROJ_DIR]
```bash
greene> 
  cd /scratch/$USER/github-fork/mlcommons/benchmarks/cloudmask/target/greene_v0.5
[PROJ_DIR]>
```

### Get a Container Image
```bash
# pull an image from docker
# rename the image (should be: tensorflow_22.10-tf2-py3.sif) to cloudmask.sif

[PROJ_DIR]> 
  singularity pull docker://nvcr.io/nvidia/tensorflow:22.10-tf2-py3
  mv tensorflow_22.10-tf2-py3.sif cloudmask.sif
```

### Get an Overlay Image
<mark>Follow this subsection, if you have a NYU Greene account. Otherwise, skip to Alternative (next subsection)</mark>

* First, copy the zipped overlay image from Greene public directory into [PROJ_DIR] and unzip

```bash
[PROJ_DIR]> 
  cp -rp /scratch/work/public/overlay-fs-ext3/overlay-15GB-500K.ext3.gz .
  gunzip overlay-15GB-500K.ext3.gz
```

### Alternatively, you can create an overlay file from scratch
Caveat: you need a Singularity version of 3.8 or above to execute the create overlay command.

```bash
# check singularity version, with size 15*1024 = 15360.

[PROJ_DIR]> 
  singularity --version
 singularity overlay create --size 15360 [overlay-image]
```

If you name [overlay-image] different from <mark>"overlay-15GB-500K.ext3"</mark>, make sure to adjust accordingly in the following steps.

### Set up the overlay image with Miniconda

```bash
[PROJ_DIR]> 
  singularity exec --overlay overlay-15GB-500K.ext3:rw cloudmask.sif /bin/bash
```

After running this command, you should see a bash shell inside the referenced singularity container overlayed with the <mark>overlay-15GB-500K.ext3</mark> file.

```bash
Singularity> 
  wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
  bash Miniconda3-latest-Linux-x86_64.sh -b -p /ext3/miniconda3
# rm Miniconda3-latest-Linux-x86_64.sh # you can remove this file
```

After we are done with the above, we need to use editor (nano, emacs, vim, etc..) to create a wrapper script <mark>/ext3/env.sh</mark>, which will be saved in the overlay image.

```bash
Singularity> 
  touch /ext3/env.sh
  nano /ext3/env.sh
```

TODO: one should not need to use nano, instead we should save the emv.sh script in github and copy in some form

The <mark>/ext3/env.sh</mark> should contain the following lines:

```bash
#!/bin/bash

source /ext3/miniconda3/etc/profile.d/conda.sh
export PATH=/ext3/miniconda3/bin:$PATH
export PYTHONPATH=/ext3/miniconda3/bin:$PATH
```

We need to activate the conda environment with this command:

```bash
Singularity> 
  source /ext3/env.sh
```

Now, we are ready to update and install packages using conda.

```bash
Singularity> 
  conda update -n base conda -y
  conda clean --all --yes
  conda install pip -y
  conda install ipykernel -y
```

Confirm everything is working as expected:
```bash
Singularity> 
  unset -f which
  which conda
  # output: /ext3/miniconda3/bin/conda
  which python
  # output: /ext3/miniconda3/bin/python
  python --version
  # output: Python 3.11.4
  which pip
  # output: /ext3/miniconda3/bin/pip
  exit
  # exit Singularity
```

### Run Singularity in Slurm

<mark>WARNING!!! Make sure you have setup virtual environment ENV3 in your $USER_SCRATCH path. tmptest-singularity.slurm has dependencies on ENV3, which you can refer to in README-Gregor.md</mark>

Rename the overlay image

```bash
[PROJ_DIR]> 
  mv overlay-15GB-500K.ext3 tmptest-overlay-image
```
Do a test run. 

* config_simple.yaml: change experiment.epoch in to 1
* config_simple.yaml: adjust model_file to fit your path
* config_simple.yaml: adjust output_dir to fit your path
* tmptest-singularity.slurm: change job-name epoch to 1
* tmptest-singularity.slurm: change to #SBATCH --time=00:30:00
* tmptest-singularity.slurm: adjust $USER_SCRATCH to fit your path

Create an outputs directory to gather outputs.
And submit the job to SLURM
```bash
[PROJ_DIR]> 
  mkdir -p outputs/slstr_cloud/
  sbatch tmptest-singularity.slurm
  # You see how the job is processing
  make status
```

After the job is done, you can check the result in output/


## 2. GRCtest_reproduce_experiments.sh ("New")

It is an automation script that allows you to run multiple experiments, varying on epoch and repeat.

### What has changed from reproduce_experiments.sh ("Old")

* Old creates arrays of pairs of config*.yaml and slurm script, and floods [PROJ_DIR]
* New creates those files and organize them in two subdirectories: <mark>config_reproduce_experiments/</mark> and <mark>slurm_reproduce_experiments/</mark>
* New also provides two variables ($config_file, $slurm_script) to change. By default, they are set as the following:

```bash
slurm_script="tmptest-singularity.slurm"
config_file="config_simple.yaml"
```

### How to run GRCtest_reproduce_experiments.sh

1. Change variables ($epochsArray, $timesArray, $REPEAT) using editor

For this example, I want to run the experiment with epoch 200 and repeat 5. You will need to adjust timesArray accordingly, match time with epoch.

```bash
# epochsArray=(1 5 10 20 30 50 80 100 200)
epochsArray=(200)
# timesArray=("00:30:00" "00:40:00" "00:50:00" "01:10:00" "01:30:00" "02:30:00" "3:00:00" "4:00:00" "13:00:00")
timesArray=("13:00:00")
# REPEAT=5
REPEAT=5
```

2. cd to [PROJ_DIR] and run the script

```bash
greene> cd /scratch/$USER/github-fork/mlcommons/benchmarks/cloudmask/target/greene_v0.5
[PROJ_DIR]> bash GRCtest_reproduce_experiments.sh
```

<mark>WARNING!!! ONLY RUN GRCtest_reproduce_experiments.sh ONE AT A TIME. OTHERWISE, YOU WON'T BE ABLE TO TELL RESULTS FROM ONE REPRODUCE RUN FROM ANOTHER.</mark>

Adviced method

1. First, run clean_outputs.sh to get your [PROJ_DIR] ready for experiment
2. Second, run GRCtest_reproduce_experiments.sh
3. Lastly, run archive_outputs.sh to archive the outputs

For more information on clean_outputs.sh and archive_outputs.sh, please see section 4 Helper Scripts.

```bash
[PROJ_DIR]> 
  bash clean_outputs.sh
  bash GRCtest_reproduce_experiments.sh
  bash archive_outputs.sh
```

## 3. Early_stoppage

### Toggle for early_stoppage

The toggle is in config_simple.yaml

```yaml
hyperparameter:
    early_stoppage: True
...
...
...
experiment:
    early_stoppage_tolerance: 25
```

To turn early_stoppage off, set early_stoppage to False, vice versa. Your can also change the tolerance (default is 25) to change the patience.

Once changing is done, you can run experiments with or without early stopping (also works for GRCtest_reproduce_experiments.sh).


## 4. Helper Scripts

There are two helper scripts: clean_outputs.sh and archive_outputs.sh

### clean_outputs.sh

This is an automation bash script that helps you clean up all the outputs resulting from running experiments. BE CAREFUL WHEN USING IT!!

It is a good practice to run clean_outputs.sh before running experiments, so you have a clean [PROJ_DIR] ready.

#### Understand what clean_outputs.sh deletes

* All output and error files in [PROJ_DIR]/outputs/ (including gpu0.log), and files in [PROJ_DIR]/outputs/slstr_cloud
* config_reproduce_experiments/
* slurm_reproduce_experiments/
* \_\_pycache\_\_
* Trained cloudModel (e.g. card_name_*)
* Logs (cloudmask logs, mlperf logs)

```bash
# For illustration, DO NOT RUN
mlperf_cloudmask*.log
cloudmask_*.log
```

#### How to run clean_outputs.sh

```bash
[PROJ_DIR]> 
  bash clean_outputs.sh
```

### archive_outputs.sh

This is an automation bash script that helps you archive all the outputs resulting from running experiments.

#### What does archive_outputs.sh do?

* its goal is to completely archive the relavent experiment results
* it saves all experiment results to [PROJ_DIR]/archive_results/[Date]\_epoch[#]\_repeat[#]\_[no_]early_stoppage

#### How to run archive_outputs.sh

archive_outputs.sh takes 4 ordered arguments, representing (run_date, epoch, repeat, early_stoppage) respectively.

Here is an exmaple, where we use GRCtest_reproduce_experiments.sh to run a batch of experiments with (run_date 9-29-2023, epoch 200, repeat 10, early_stoppage 0). 

[Note: for early_stoppage, we use 0 to represent no early stoppage, and 1 to represent early stoppage.]

```bash
# An example. 
[PROJ_DIR]> 
  bash archive_outputs.sh 9-29-2023 200 10 0
  ls archive_outputs
  # expected output: 9-29-2023-epoch200-repeat10-no_earlystoppage/
```