# Rivanna Setup

## Set-up Git

To set up git on your machine, you need to make sure that on all machines that you access git and make commits use the same username. It is also advisable that you set the editor to an editor that you like and is supported uniformly on all machines that you intend to make git commits from. Good examples are emacs, vim, vi, pico, nano. Make sure the one you pick is supported.

I am using here the user Gregor von Laszewski as an example, please adapt to your name and email accordingly. To find out the values you set you can use the command

```bash
gitconfig -l
```

Which should return something like 

```
user.email=laszewski@gmail.com
user.name=Gregor von Laszewski
push.default=matching
core.editor=emacs
```

If some of the values are different or do not match your username, first and lastname or e-mail, please adjust them with 

```bash
rivanna> git config pull.rebase false
rivanna> git config --global user.name "Gregor von Laszewski"
rivanna> git config --global user.email "laszewski@gmail.com"
rivanna> git config --global core.editor "emacs"
```

## Get Interactive node and login

As we want to install a working version of python, we will do this initially through an interactive node. This gurantees that we use the same version of python when we run the code. However this step can also be likely performed on the frontend of rivanna without an interactive node. We do this only to be extra careful.

For you ti use rivanna, you need to have a valid partition and allocation. Thise working with Gregor can use 

* partition: bii-gpu
* allocaton: bii_dsc_community

You will need to be added to the UVA group bii_dsc_community at: https://mygroups.virginia.edu/groups/ by Gregor. Please contact him.

a100:

```bash
ijob -c 1 --time=3:00:00 --partition=bii-gpu --account=bii_dsc_community --gres=gpu:a100 --reservation=bi_fox_dgx --constraint=a100_80gb
```

Not sure where this command came from:

```bash
srun --partition=bii-gpu -A bii_dsc_community --gres=gpu:v100:1 --pty --mem=64G --time 02:00:00 /bin/bash
```


## Simple Setup

This step must be done on an interactive node. HOw to get one is explained in the previous step.


```bash
rm -rf init-cloudmask.bash
curl -O https://raw.githubusercontent.com/laszewsk/mlcommons/main/benchmarks/cloudmask/experiments/rivanna/init-cloudmask.bash
source init-cloudmask.bash
```


## Generating Experiment Configurations

The following commands need to be executed in the node to set up the code (alternatively they can be executed on the rivanna frontend).

```bash
rivanna> export GITUSER=laszewsk
rivanna> export USER_SCRATCH=/scratch/$USER
rivanna> export PROJECT_DIR=$USER_SCRATCH/mlcommons/benchmarks/cloudmask
rivanna> export PROJECT_DATA=$USER_SCRATCH/data

rivanna> mkdir -p $USER_SCRATCH
rivanna> cd $USER_SCRATCH

rivanna> time git clone https://github.com/$GITUSER/mlcommons.git

rivanna> cd $PROJECT_DIR
```

If you already have set up this environment you can reactivate it simply with 

```bash
node> source init.bash
```

## Set-up Python

To set up python it is a good idea to explre wha is supported by the system as default.

Use the command

```bash
node> module spider anaconda
node> module spider cudnn
```

You will see something like 

```
anaconda/2019.10-py2.7
anaconda/2020.11-py3.8
cudnn/7.6.5.32
cudnn/8.0.5.39
cudnn/8.2.4.15
```

Pick a version using python 3 and cudnn with 8 and above. Then we create a python virtual env called ENV3 that we will be using. The following steps will set this up.


```bash
node> module purge
node> module load  gcc/9.2.0  cuda/11.0.228  openmpi/3.1.6 python/3.8.8
# node> time python -m venv ./ENV3
node> time python3 -m venv $USER_SCRATCH/ENV3
node> source $USER_SCRATCH/ENV3/bin/activate

node> pip install pip -U
node> which python

```

This should return $USER_SCRATCH/ENV3/bin/python

```bash
node> cd $PROJECT_DIR/experiments/rivanna
node> time make requirements
```

This command takes about 5 minutes 10 seconds to execute on rivana

## Obtain the data

```bash
time time make data
```

This command takes about 1hr to execute on rivanna

## Run the code


```bash
rivanna> cd $PROJECT_DIR/experiments/rivanna/
rivanna> rm -rf outputs
rivanna> mkdir -p outputs
rivanna> sbatch simple.slurm
rivanna> squeue -u $USER
```


---
**NOT TESTED FROM HERE ON**
---


# Parameterized jobs for rivanna with cloudmesh-sbatch

This version of cloudmask uses [cloudmesh-sbatch](https://github.com/cloudmesh/cloudmesh-sbatch) 
to coordinate a parameter sweep over hyperparameters. It significantly simplifies managing
different experiments as it stores the output in a directory format that 
simplifies analysis.

## 1. Programming Environment Prerequisites

### 1.1 LaTeX (optional)

We assume if you like to use the automated report generated (under
development) you have full version of latex installed

```bash
module load texlive
```

If you do not want to create the reports, please skip this step.

### 1.2 Python 3

We assume you have a fairly new version of Python installed susch as 
Python 3.10.8. However, a version greater than 3.10.4 will also do.
We install the version of python to be used in a python venv and 
install in it the required packages. Please note that as of
Dec 2022, python 3.11 is not supported by anaconda which we 
use for this project as it is the recommended version by the 
rivanna support staff.

If you have executed this step previously, you only have to say 

```bash
module purge
module load anaconda
source activate python310
source ~/ENV3/bin/activate
```

Otherwise, do the following:

```bash
module purge
module load anaconda

conda create -y -n python310 python=3.10
source activate python310

python -m venv ~/ENV3
source ~/ENV3/bin/activate
mkdir ~/cm
cd ~/cm
pip install cloudmesh-installer
cloudmesh-installer get sbatch
cms help
```

In either case your command promt will have the prefix `(ENV3)`.

Note that we use two different python environment. 
One for running sbatch, the other in whcih we run tensorflow, which will be 
setup automatically in a later step.


## 2. Generating experiment configurations

Choose a PROJECT_DIR where you like to install the code. Rivanna offers some temporary
space in the /scratch directory. 

```bash
export PROJECT_DIR=/scratch/$USER
mkdir -p ${PROJECT_DIR}
cd ${PROJECT_DIR}
git clone ssh://git@github.com/laszewsk/mlcommons.git
git checkout main
cd mlcommons/benchmarks/cloudmask/experiments/rivanna
```

In case you would like to have a different branch other than
main, please use the name of the branch in the `git checkout`
command.

## 3. Obtaining the data

Next we obtain the data. The command uses an aws call to download both
daytime and nighttime images of the sky. The total space the data dir
will take up is 180GB. It will take around 20 minutes to finish downloading
the data. In case the data was previously downloaded, this stepp will take 15 
seconds.


```bash
time make data
```

The data is downloaded to 

```
$(PROJECT_DIR)/mlcommons/benchmarks/cloudmask/data
```

## 4. Generate parameterized jobs

Next we generate some parameterized jobs. These runs are controlled with two files.

* `config.yaml` -- Specifies the parameters for cloudmask and the 
  SLURM scripts.

* `ubuntu.in.slurm` -- Specifies the slurm script in which the parameters 
  defined by `config.yaml` will be substituted.

  This is simply done via the following make commands after you have selected 
  appropriate values in the yaml file. 

  ```bash
  # setup venv
  make setup  # this takes minutes 
  make project # this takes less then 15 seconds
  ```

  The makefile targets will generate two files and a subdirectory with individual 
  experiments:

* `project.sh` -- Is a file that contains each individual job submission 
  based on the parameter sweep that is defined by the YAML file.
* `project.json` -- Is a file that contains the metadata associated with the 
  individual job submissions generated from the experiment permutations
* `project` -- Is a directory that includes for each individual experiment a 
  slurm script and a yaml file.

## 5. Running the parameterized jobs

Before executing the `jobs-project.sh` script, it is advised that you inspect the 
output of the files and directories. 

Be aware that many jobs may take hours to complete.  We provide here a simple 
estimate while using some predefined model as specified in our yaml file.

A100

| Epochs | Time in s |        Time |
|-------:|----------:|------------:|
|      1 |      2578 |     42m 58s |
|     10 |      3186 |      53m 6s |
|     30 |      4757 | 1hr 19m 17s |
|     50 |      6434 | 1hr 47m 14s |
|    100 |     11098 |  3hr 4m 58s |

V100

| Epochs | Time in s |        Time |
|-------:|----------:|------------:|
|      1 |      2600 |     43m 20s |
|     10 |      4330 | 1hr 12m 10s |
|     30 |      8240 | 2hr 17m 20s |
|     50 |     11340 |      3hr 9m |
|    100 |     22274 | 6hr 11m 15s |

An example on how to look at a slurm script (assuming we use an a100 in the YAML file) is 

```bash
less project/card_name_a100_gpu_count_1_cpu_num_1_mem_64GB_repeat_1_epoch_10/rivanna.slurm
```

To look at the yaml file for this experiment, use 

```bash
less project/card_name_a100_gpu_count_1_cpu_num_1_mem_64GB_repeat_1_epoch_10/config.yaml
```

or simply call  which uses emacs to open both files from the first parameterized job.

```bash
make inspect
```

Note: to exit emacs, press `Ctrl+x` and then `Ctrl+c` to return to your normal prompt.

## 6. Running the experiments

If all the output from above looks correct, you can execute the jobs
by running the last two scripts that are generated by cms sbatch
generate submit.

```bash
make run
# Submitted batch job 12345678
```

The number will be different for you.

To find out the status you can do the following commands. The first
looks up the job by the id, the second will list all jobs you
submitted. if you just have one job it will return just that one
job. `make status` is a shortcut to see all jobs of a user.

```bash
make status
```


The `make run` will submit the job to slurm, and the
notebook file will be outputted in the
`$(pwd)/cloudmask/<experiment_id>` directory.

You can see the progress of each job by inspecting the `*.out` and
`*.error` files located in the `$(pwd)/cloudmask/<experiment_id>`). 
The following log files will be created:

* `cloudmask-%j.log` -- Output created by SLURM from whole job.in.slurm script.
* `cloudmask-%j.error` -- Error messages caught by SLURM when either the job 
   writes to stderr, or an error is caught by SLURM.
* `gpu0.log` -- Logfile with Temperatures and energy values for the GPU0. This 
   assumes you run the code on the GPU with number 0.
* `mlperf_cloudmask.log` -- Logfile that records all MLCommons logging events.
* `cloudmask_run.log` --  Logfile for recording runtimes.
* `output.log` -- Logfile that covers all the output of the `slstr_cloud.py` file.

To watch the output dynamically for an example run you can use the command 

```bash
tail -f  project/card_name_a100_gpu_count_1_cpu_num_6_mem_64GB_TFTTransformerepochs_2/*.out
```

you will have to change the second parameter in the path according to your 
hyperparameters and what you like to watch 

The file `output.log` contains a convenient human readable summary of the various portions of the program execution generated with cloudmesh StopWatch. It includes details of the compute node, as well as runtimes.


```
+---------------------------------+---------------------------------------------------+
| Attribute                       | Value                                             |
|---------------------------------+---------------------------------------------------|
| ANSI_COLOR                      | "0;31"                                            |
| BUG_REPORT_URL                  | "https://bugs.centos.org/"                        |
| CENTOS_MANTISBT_PROJECT         | "CentOS-7"                                        |
| CENTOS_MANTISBT_PROJECT_VERSION | "7"                                               |
| CPE_NAME                        | "cpe:/o:centos:centos:7"                          |
| HOME_URL                        | "https://www.centos.org/"                         |
| ID                              | "centos"                                          |
| ID_LIKE                         | "rhel fedora"                                     |
| NAME                            | "CentOS Linux"                                    |
| PRETTY_NAME                     | "CentOS Linux 7 (Core)"                           |
| REDHAT_SUPPORT_PRODUCT          | "centos"                                          |
| REDHAT_SUPPORT_PRODUCT_VERSION  | "7"                                               |
| VERSION                         | "7 (Core)"                                        |
| VERSION_ID                      | "7"                                               |
| cpu                             | Intel(R) Xeon(R) Gold 6230 CPU @ 2.10GHz          |
| cpu_cores                       | 40                                                |
| cpu_count                       | 40                                                |
| cpu_threads                     | 40                                                |
| date                            | 2022-12-07 15:42:28.276533                        |
| frequency                       | scpufreq(current=2100.0, min=0.0, max=0.0)        |
| mem.active                      | 59.0 GiB                                          |
| mem.available                   | 308.5 GiB                                         |
| mem.free                        | 297.8 GiB                                         |
| mem.inactive                    | 9.2 GiB                                           |
| mem.percent                     | 18.1 %                                            |
| mem.total                       | 376.5 GiB                                         |
| mem.used                        | 61.4 GiB                                          |
| platform.version                | #1 SMP Wed Feb 23 16:47:03 UTC 2022               |
| python                          | 3.10.8 (main, Nov 24 2022, 14:13:03) [GCC 11.2.0] |
| python.pip                      | 22.2.2                                            |
| python.version                  | 3.10.8                                            |
| sys.platform                    | linux                                             |
| uname.machine                   | x86_64                                            |
| uname.node                      | udc-aj36-36                                       |
| uname.processor                 | x86_64                                            |
| uname.release                   | 3.10.0-1160.59.1.el7.x86_64                       |
| uname.system                    | Linux                                             |
| uname.version                   | #1 SMP Wed Feb 23 16:47:03 UTC 2022               |
| user                            | Gregor von Laszewski                              |
+---------------------------------+---------------------------------------------------+
```

```
+-------------------------+----------+---------+ ...
| Name                    | Status   |    Time | ...
|-------------------------+----------+---------+ ...
| total                   | ok       | 900.437 | ...
| training                | ok       | 751.567 | ...
| loaddata                | ok       |   2.313 | ...
| training_on_mutiple_GPU | ok       | 744.44  | ...
| inference               | ok       | 148.178 | ...
+-------------------------+----------+---------+ ...
```

This data is also available as CSV entries and can conveniently be grepped with 

```bash
$ grep "# csv" output.log
```

for further automated processing.


## 7. Generate Report

**TODO:** not implemented

```bash
pdflatex report.tex
pdflatex report.tex
# bibtex report.bib
pdflatex report.tex
```

This will create a pdf named `report.pdf`.  You can download this to
your local to view the output to view the report generated as a result
of the execution.
