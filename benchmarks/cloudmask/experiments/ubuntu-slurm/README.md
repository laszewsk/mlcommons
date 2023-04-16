# Parameterized jobs for Ubuntu slurm with cloudmesh-sbatch

This version of cloudmask uses [cloudmesh-sbatch](https://github.com/cloudmesh/cloudmesh-sbatch) 
to coordinate a parameter sweep over hyperparameters. It significantly simplifies managing
different experiments as it stores the output in a directory format that 
simplifies analysis.

## 1. Programming Environment Prerequisites

### 1.1 LaTeX (optional)

We assume if you like to use the automated report generated (under
development) you have full version of latex installed

```bash
which pdflatex
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


```
source ~/ENV3/bin/activate
```

Otherwise, do the following:

```bash
python -m venv ~/ENV3
source ~/ENV3/bin/activate
pip install pip -U
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

## 1.3 SLURM

### jp's installation

```bash
# sudo apt install libevent-dev autoconf git libtool flex libmunge-dev 
sudo get install munge -y
git clone https://github.com/SchedMD/slurm 
cd slurm/
./configure --enable-debug --enable-deprecated --with-munge
sudo make -j install
sudo mkdir -p /etc/slurm-llnl/
sudo cp ./etc/slurm.conf.example /etc/slurm-llnl/slurm.conf
# edit the config file to use your computers hostname and specifications.
# make sure in the config file to make the slurmuser=root
# and make the slurmctldhost=YourHostnameGoesHere
# and make the NodeName=YourHostNameGoesHere
sudo nano /etc/slurm-llnl/slurm.conf
```
sudo cp  etc/slurmctld.service /lib/systemd/system


### Install

```bash
sudo apt install libevent-dev autoconf git libtool flex libmunge-dev munge -y
git clone https://github.com/SchedMD/slurm 
cd slurm/
./configure --enable-debug --enable-deprecated --with-munge
make -j
sudo make -j install
```

### Uninstall

```bash
sudo apt-get remove slurm

sudo apt-get -y purge munge
sudo apt-get remove munge
```

### Setup

```bash
sudo slurmctld -c -D -f /etc/slurm-llnl/slurm.conf -i
# open another terminal and execute the following command
sudo slurmd -f /etc/slurm-llnl/slurm.conf
```

https://github.com/cloudmesh/cloudmesh-sbatch#slurm-on-a-single-computer-ubuntu-2004

https://gist.github.com/ckandoth/2acef6310041244a690e4c08d2610423

```bash
$ sudo systemctl start slurmctld -f /etc/slurm-llnl/slurm.conf
$ sudo systemctl start slurmd -f /etc/slurm-llnl/slurm.conf
```

We assume you have SLURM installed

```bash
which sbatch
whcih srun
which squeue
which scontrol
```

Instalation instruction are provided her ???. TODO: Locate the slurm instalation instruction, it may be in the cloudmesh-mpi repo???


## 2. Generating experiment configurations

Choose a PROJECT_DIR where you like to install the code. Rivanna offers some temporary
space in the /project1 directory. Please replace this directory accordingly.

```bash
export PROJECT_DIR=/project1/$USER
mkdir -p ${PROJECT_DIR}
cd ${PROJECT_DIR}
git clone ssh://git@github.com/laszewsk/mlcommons.git
git checkout main
cd mlcommons/benchmarks/cloudmask/experiments/ubuntu-sh
pip install -r requirements
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

unbuntu-sh Gregors machine 117m23.104s



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
|    100 |     22274 | 6hr 11m 14s |

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
