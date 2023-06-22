# Benchmarking on NYU HPC Greene Cluster


## Nomencalture

* The frontend node (sometimes called head node) of Greene is indicated with `green>`
* A worker node is indicated with `node>`
* YOur computer in fornt of you is indicated with `computer>`

## Pre-requisite

Before using  Greene HPC you need to obtain an account in it while working 
with faculty or staff to get permission to use it.  To obtain an account follow the documentation at 

* [NYU HPC 
Account Creation](https://www.nyu.edu/life/information-technology/research-computing-services/high-performance-computing/high-performance-computing-nyu-it/hpc-accounts-and-eligibility.html).

## Account setup

To use Greene efficently for this project, you needs to install a number of brograms and set some configurations. This includes

* SSH
* Github
* Python
* AWS CLI client

We will discuss each of them in this document.

## SSH setup

In order to log into Greene it is advised to use ssh. SSH is available on most computers and the Documentation of Greene includes [hints](https://TBD) on how to set it up.

**Note for windows users:** if you have a windows machine it is bets to use 
[gitbash](https://TBD) as it behaves just like bash on linux and 
MacOS thus unifying the documentation for all platforms, 
please download and install gitbash.

From her on we asumme everything is done in bash terminals.

## Access grene from a local computer with ssh

To use ssh you need to first create an ssh key. If you have not yet done so, you need to use the command

```
computer>
  ssh-keygen
```

Please leve the defaults, but make sure that your passphrase 
is a strong passphrase and not an empty pass phrase. Those using empty passphrases need to take a security class and should regenerate their keys to use one with passphrase.

To not always typ in the passphrase you can use ssh agent as follows on your computer. On mac and Linux ssh-agent is usually started automatically and you just can use ssh-add. On windows you do 

```
computer>
  eval `ssh-agent`
  ssh-add
```

As Greene has multiple login nodes and they are not set up with different 
host certifcates, it is important to register each login node so that the known_host file does not allerat you with duplication of host certificates.

Please place the following in your `~/.ssh/config` file

This examle assumes you have the username `abc123` on greene. Please replace it with you user name.

```
ServerAliveInterval 60

Host *.hpc.nyu.edu
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  LogLevel ERROR
  
Host greene
     User abc123
     HostName greene.hpc.nyu.edu
     IdentityFile ~/.ssh/id_rsa.pub

Host greene1
     User abc123
     HostName 216.165.13.137
     IdentityFile ~/.ssh/id_rsa.pub

Host greene2
     User abc123
     HostName 216.165.13.138
     IdentityFile ~/.ssh/id_rsa.pub

Host greene3
     User abc123
     HostName 216.165.13.139
     IdentityFile ~/.ssh/id_rsa.pub
```

After instalation of the config file, you need to copy the public key into Grene authorized_keys file. This is bets done with the command

```
computer>
  ssh-copy-id greene
```

## Greene ssh tunnel

A different way to set up ssh for Greene is to use the following `~/.ssh/config` file

```
Host *.hpc.nyu.edu
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  LogLevel ERROR

Host greenetunnel
  HostName gw.hpc.nyu.edu
  ForwardX11 no
  LocalForward 8027 greene.hpc.nyu.edu:22
  User <Your NetID>

Host greene
  HostName localhost
  Port 8027
  ForwardX11 yes
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  LogLevel ERROR
  User <Your NetID>
```

Now you can create in a bash terminal a tunnel with 

```bash
ssh greenetunnel
```

This window has to stay open. Next, you can log into greene on another terminal with 

```bash
ssh greene
```

In case you like to forward X11 you can use

```bash
ssh -Y greene
```


## Set-up Git

As the code is amanged in github, you need to make sure github is propperly configures on all machines This includes your computer and Greene this you execute the following commands while making appropriate adjustments. 

```bash
computer> 
  git config pull.rebase false
  git config --global user.name "FIRST_NAME LAST_NAME"
  git config --global user.email "MY_NAME@example.com"
  git config --global core.editor "nano"
```

```bash
greene> 
  git config pull.rebase false
  git config --global user.name "FIRST_NAME LAST_NAME"
  git config --global user.email "MY_NAME@example.com"
  git config --global core.editor "nano"
```

## Installing Python

First you need a working version of python on Greene that works on the frontend 
node as well os on the worker nodes. To gurantee that we have all needed 
libraries such as CUDA installed we execute the python install from a worker 
node instead of the frontend node.

Thus we start first an interactive worker node:

```bash
greene>
  srun --gres=gpu:v100:1 --pty --mem=64G --time 02:00:00 /bin/bash
```

This will create an interactive worker node, indicated with `node>` 
in the following documentation.  Then on the node execute

```bash
node> 
  module purge
  module load anaconda3/2020.07
  module load cudnn/8.6.0.163-cuda11
  conda create -p $USER_SCRATCH/python310 python=3.10
  conda activate $USER_SCRATCH/python310
  python3 -m venv $USER_SCRATCH/ENV3
  conda deactivate
  source $USER_SCRATCH/ENV3/bin/activate
  pip install pip -U
  which python
  python --version
```

This should return 

```
$USER_SCRATCH/ENV3/bin/python
3.10
```

This is a one time set up. 
Onece this is set up, you do not have to do the reinstall it again. 
However, if you log into Greene wit a new terminal, 
you must activate python if you want to use python, with

```bash
source $USER_SCRATCH/ENV3/bin/activate
```

This is done regardless if you use the frontend node or a worker node

## Data download

### Install aws client

We assume that you have installed python as discussed in the 
Python setup section. E.g.

```bash
greene>
  source $USER_SCRATCH/ENV3/bin/activate
```

On Greene we do not have sudo priviedges, so we install it in the home dir with 

```bash
mkdir ~/tmp
cd ~/tmp
curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip awscliv2.zip 
./aws/install -b ~/bin/aws -i ~/aws-cli
```

Set $PATH environment variable

```
$ echo $PATH | grep ~/bin     // See if $PATH contains ~/bin (output will be empty if it doesn't)
$ export PATH=~/bin:$PATH     // Add ~/bin to $PATH if necessary
```

Best is to add it to your .bashrc file and add the line 

```
export PATH=~/bin:$PATH     // Add ~/bin to $PATH if necessary
```

#### Verify version 

```
which aws
aws --version
```

## Modification of .bashrc

As we ahve many different parameters that will be used repeatedly when we log in we recommend that you add the following to your `.bashrc` file. Please use your favorte editor

```bash
greene>
  nano ~/.bashrc
```

In this file add 

```
export PATH=~/bin:$PATH 

export USER_SCRATCH=/scratch/$USER/github-fork
export PROJECT_DIR=$USER_SCRATCH/mlcommons/benchmarks/cloudmask
export PROJECT_DATA=$USER_SCRATCH/data
#
# current existing downloaded dataset is located at
#
# export PROJECT_DATA=/scratch/vc2209/github-fork/data


source $USER_SCRATCH/ENV3/bin/activate
```

## Installing the code

### Get Interactive node and login

```bash
srun --gres=gpu:v100:1 --pty --mem=64G --time 02:00:00 /bin/bash
```

### Set experiment directories

### Greene

```bash
node> 
  export USER_SCRATCH=/scratch/$USER/github-fork
  export PROJECT_DIR=$USER_SCRATCH/mlcommons/benchmarks/cloudmask
  export PROJECT_DATA=$USER_SCRATCH/data
```

### AMD5950X Desktop

Do not use, its here for future documentation

```bash
computer>
  export PROJECT_SCRATCH=/home/$USER/Desktop/github/mlcommons
  export PROJECT_DIR=$USER_SCRATCH/mlcommons/benchmarks/cloudmask
  export PROJECT_DATA=/scratch2/data/cloudmask/data
```



## Generating Experiment Configurations

Now you need to download and install the code. Please only clone one version of the repository. This depends on wht user you are. For production use `https://github.com/laszewsk/mlcommons.git`

```bash

greene> 
  mkdir -p $USER_SCRATCH
  mkdir -p $PROJECT_DATA
  cd $USER_SCRATCH
  git clone https://github.com/laszewsk/mlcommons.git
  node(alternative 1)> git clone https://github.com/rg3515/mlcommons.git
  node(alternative2 )> git clone https://github.com/VarshithaChennamsetti/mlcommons.git

node> cd $PROJECT_DIR
```

## Updateing the code once the directories already exist

In case you previously cloned the code you only have to update it

```
node> 
  cd $PROJECT_DIR
  git pull
```


## Set-up Python requirements

Make sure to change the paths in the 'config.yaml' file to appropriate locations.

```bash
node> 
  cd $PROJECT_DIR/experiments/greene/
  time make requirements
```

This command takes about 1 minute to execute.

## Obtain the data

```bash
node> 
  time make data
```

This command takes about 1hr to execute.

From now on you no longer need to use an interactive node and all submissions are managed via slurm from a frontend node.

## Run the code

```bash
greene> 
  cd $PROJECT_DIR/experiments/greene/
  mkdir -p outputs
  sbatch simple.slurm
  squeue -u $USER
```

To see the output use the comamnd 

```
greene>
  cat *.out
  cat *.err
  cat outputs/gpu0.log 
```

---
NOTE: **RG PLEASE TRY TO GET ALL THE STEPS TILL HERE**
---

## Reproduce Experiments

A script has developed that replicates the more bpowerful cloudmesh-sbatch program which we will document ASAP but is already available on the production code Makefile in the greene code experiemnet.

cloudmesh s-batch can generate a number of subdirectories with appropriate copies of configuration files and duplication of the code for easy execution with any queuing system including SLURM which is used on Greene.

To use is, simple modify the config.in.yaml file and slurm.in.sh configuration files. To generate a script jobs.sh with all jobs to be executed use the command

make project

However the current group is using an alternative method whil executing 

```bash
bash reproduce_experiments.sh
```

## Visualize results

To visualize the graphs, pass the paths to the log files as the arguments while running the file visualizer.py

```bash
python3 visualizer.py mlperf_cloudmask_diff_epochs.log cloudmask_run_diff_epochs.log
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
cd mlcommons/benchmarks/cloudmask/experiments/rivanna
```
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

| Epochs | Time in s |    Time |
|-------:|----------:|--------:|
|      1 |       900 | 15m 00s |
|     10 |      2667 | 44m 27s |
|     30 |       ??? |     ??? |
|     50 |       ??? |     ??? |
|    100 |       ??? |     ??? |

An example on how to look at a slurm script (assuming we use an a100 in the YAML file) is 

```bash
less project/card_name_a100_gpu_count_1_cpu_num_1_mem_64GB_repeat_1_epoch_10/rivanna.slurm
```

To look at the yaml file for this experiment, use 

```bash
less project/card_name_a100_gpu_count_1_cpu_num_1_mem_64GB_repeat_1_epoch_10/config.yaml
```

or simply call  which uses emacs to open both files from the firts parameterized job.

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
