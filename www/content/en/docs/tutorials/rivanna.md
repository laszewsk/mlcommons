---
title: "Running GPU Batch jobs on Rivanna"
linkTitle: "GPU@Rivanna"
author: Grgeor von Laszewski, Robert Knuuti
date: 2017-01-05
weight: 4
description: >
  A short introduction on how to run GPU Jobs on Rivanna
---

{{% pageinfo %}}
We explain how to run GPU batch jobs using different GPU cards on
Rivanna. Rivanna is a supercomputer at the University of Virginia. This
tutorial is only useful if you can get an account on it. The 
official documentation is available at

* <https://www.rc.virginia.edu/userinfo/rivanna/overview/>

However, it includes some issues and does not explain certain
important aspects for using GPUs on it. Therefore, this guide has been
created.

**PLEASE HELP US IMPROVE THIS GUIDE**
{{% /pageinfo %}}


{{< alert color="warning" title="Requirements" >}}
We require that you have

* A valid account on Rivanna
* A valid accounting group allowing you to run GPU jobs on Rivanna

{{< /alert >}}

## Introduction

Rivanna is the High-Performance Computing (HPC) cluster 
managed by University of Virginia's Research Computing. Rivanna is
composed 575 nodes with a total of 20,476 cores and 8PB of different
types of storage. Table 1 shows an overview of the compute
nodes. Some of the compute nodes also includes these GPUs:

* [A100](https://www.nvidia.com/en-us/data-center/a100/),
  [K80](https://www.nvidia.com/en-gb/data-center/tesla-k80/),
  [P100](https://www.nvidia.com/en-us/data-center/tesla-p100/),
  [V100](https://www.nvidia.com/en-us/data-center/v100/),
  [RTX2080](https://www.nvidia.com/en-us/geforce/20-series/),
  and
  [RTX3090](https://www.nvidia.com/en-us/geforce/graphics-cards/30-series/rtx-3090/)

**Table 1:** GPUs on Rivanna

| Cores/Node   | Memory/Node   | Specialty Hardware   | GPU memory/Device   | GPU devices/Node   | \# of Nodes   |
| ------------ | ------------- | -------------------- | ------------------- | ------------------ | ------------- |
| 40           | 354GB         | \-                   | \-                  | \-                 | 1             |
| 20           | 127GB         | \-                   | \-                  | \-                 | 115           |
| 28           | 255GB         | \-                   | \-                  | \-                 | 25            |
| 40           | 768GB         | \-                   | \-                  | \-                 | 34            |
| 40           | 384GB         | \-                   | \-                  | \-                 | 348           |
| 24           | 550GB         | \-                   | \-                  | \-                 | 4             |
| 16           | 1000GB        | \-                   | \-                  | \-                 | 5             |
| 48           | 1500GB        | \-                   | \-                  | \-                 | 6             |
| 64           | 180GB         | KNL                  | \-                  | \-                 | 8             |
| 128          | 1000GB        | GPU: A100            | 40GB                | 8                  | 2             |
| 28           | 255GB         | GPU: K80             | 11GB                | 8                  | 9             |
| 28           | 255GB         | GPU: P100            | 12GB                | 4                  | 3             |
| 40           | 383GB         | GPU: RTX 2080 Ti     | 11GB                | 10                 | 2             |
| 28           | 188GB         | GPU: V100            | 16GB                | 4                  | 1             |
| 40           | 384GB         | GPU: V100            | 32GB                | 4                  | 12            |


*) This information may be outdated

## Access to Rivanna

Access to Rivanna is secured by [University of Virginias
VPN](https://virginia.service-now.com/its/?id=itsweb_kb_article&sys_id=f24e5cdfdb3acb804f32fb671d9619d0). UVA
offers two different VPNs. We recommend that you install the **UVA
Anywhere VPN**. This can be installed on Linux, macOS and Windows.

After installation, you have to start the VPN. After that, you can use a
terminal to access Rivanna via ssh. If you have not used ssh, we
encourage you to read about it and explore commands such as `ssh`,
`ssh-keygen`, `ssh-copy-id`, `ssh-agent, and `ssh-add`.


{{< alert color="warning" title="Note: gitbash on Windows" >}}

Please note that on Windows, you are expected to install gitbash so
you can use the same commands and ssh logic as on Linux and Mac. For
this reason, we do not recommend `putty`, `PowerShell` or
`cmd.exe`. This is because we can do scripting the same way, even from
those running Windows, and significantly simplifies this guide.

{{< /alert >}}



We will not provide an extensive tutorial on how to use
ssh, but you can contribute it. Instead, we will summarize the most important steps:

1. Create an ssh key if you have not done that before

   ```bash
   $ ssh-keygen
   ```

   It is **VERY** important that you create the key with a strong passphrase. 

2. Add an abbreviation for Rivanna to your `~/.ssh/config` file

   Use your favorite editor. Mine is `emacs`

   emacs ~/.ssh/config

   copy and paste the following into that file, where `abc1de` is to be substituted by your
   UVA compute id.
   

   ```
   Host rivanna
     User abc1de
     HostName rivanna.hpc.virginia.edu 
     IdentityFile ~/.ssh/id_rsa.pub
   ```

   This will allow you to use `rivanna` instead of `abc1de@rivanna.hpc.virginia.edu`.
   The next steps assume you have done this and can use just `rivanna`

3. Copy your public key to rivanna

   ```bash
   $ ssh-copy-id rivanna
   ```
   
   This will copy your public key into the
   `rivanna:~/.ssh/authorized_keys` file.

4. After this step, you can use your keys to authenticate. You still
   need to be using the VPN, though.

   The most convenient system for it is Mac and Ubuntu. It
   already has a tool installed called ssh-agent and keychain. In
   Windows under gitbash you need to start it with

   ```bash
   $ eval `ssh-agent`
   ```

   First, you add the key to your session, so you do not have to
   constantly type in the password. Use the command

   ```bash
   $ ssh-add
   ```

   to test if it works, just say

   ```bash
   $ ssh rivanna hostanme
   ```

   which will print the hostname of Rivanna

   In case your machine does not run ssh-agent, you can start it
   before you type in the ssh-add command with
   
   ```bash
   $ ssh rivanna hostanme
   ```

   If everything is set up correctly, it will return  the string

   ```
   udc-ba35-36
   ```
   
5. To login to Rivanna, simply say   

   "`bash
   ssh rivanna
   ```

   If this does not work, you have made a mistake. Please, review the
   previous steps carefully.
   
## Running Jobs on Rivanna

Jobs on Rivanna can be scheduled through Slurm either as a batch job or
as an interactive job. In order to achieve this, one needs to load the
software first and create special scripts that are used to submit them
to nodes that contain the GPUs you specify.

The user documentation about this is provided here:

* <https://www.rc.virginia.edu/userinfo/rivanna/overview/#gpu-partition>

However, at the time when we looked at it, it had some mistakes and
limitations that we hope to overcome here.


### Modules


Rivanna's default mechanism of software configuration management is
done via
[modules](https://lmod.readthedocs.io/en/latest/index.html). The UVA
modules documentation is provided through this
[link](https://www.rc.virginia.edu/userinfo/rivanna/software/modules/).

Modules provide the ability to load a particular software stack and
configuration into your shell but also into your batch jobs. You can
load multiple modules in your environment to load them in order.

To list the available modules, log into Rivanna and use the command

```
$ module available
```

To list aproximately, the python modules use

```
$ module available py
```

It will return all modules that have py in it. Please chose those that
look like python modules.

To probe for deep learning modules, use  something similar to

```
$ module available cuda tensorflow pytorch mxnet nvidia cudnn
```


### Python

Different versions of python are available.

To load python 3.8 we can say

```bash
$ module load anaconda/2020.11-py3.8
```


To load Python 3.10.0 we can say

```
$ module load anaconda
$ conda create -n py3.10 python=3.10
$ source activate py3.10
$ python -V
Python 3.10.0
```

Please note that at this time anaconda did not support 3.10.2, which I
run personally on my computer, but from python.org.

### Adding Modules with Spider 

Details about modules can be identified with the `module spider` command.
If you type it in you get a list of many available configurations.
Spider can take a keyword and lists all available version the keyword matches.
Let us demonstrate it on 

```bash
$ module spider python
```

```
----------------------------------------------------------------------------
  python:
----------------------------------------------------------------------------
    Description:
      Python is a programming language that lets you work more effectively.

     Versions:
        python/2.7.16
        python/3.6.6
        python/3.6.8
        python/3.7.7
        python/3.8.8
     Other possible modules matches:
        biopython  openslide-python  wxpython
----------------------------------------------------------------------------
...
```

For detailed information about a specific "python" package use the module's full name.

```bash
$ module spider python/3.8.8
```

This will return a page with lots of information. The most important one for us is

```
 You will need to load all module(s) on any one of the lines below before the
 "python/3.8.8" module is available to load.

      gcc/11.2.0  openmpi/3.1.6
      gcc/9.2.0  cuda/11.0.228  openmpi/3.1.6
      gcc/9.2.0  mvapich2/2.3.3
      gcc/9.2.0  openmpi/3.1.6
      gcccuda/9.2.0_11.0.228  openmpi/3.1.6
      goolfc/9.2.0_3.1.6_11.0.228
 ```

Here you see various options that need to be loaded in **BEFORE** you load python.

Thus to properly load python 3.8.8 you need to say (if this is what you chose):

```
module load gcc/11.2.0
module load openmpi/3.1.6
module spider python/3.8.8
```

#### Modules for tensorflow

```
module load singularity/3.7.1
module load tensorflow/2.7.0
```

#### Modules for pytorch

```
module load singularity/3.7.1
module lod pytorch/1.10.0
```


### Containers

Rivanna uses singularity as container technology. The documentation
specific to singularity for Rivanna is avalable at this
[link](https://www.rc.virginia.edu/userinfo/rivanna/software/containers/)

Singularity needs to be also loaded as a module befor it can be used.

Singularity containers have the ability to access
[GPUs](https://www.rc.virginia.edu/userinfo/rivanna/software/containers/#running-gpu-images)
via a passthrough using NVidia drivers. Once you load singularity you
can use it as follows:

```bash
singularity <cmd> --nv <imagefile> <args>
```

The container will be used inside a job.

### Jobs

More detail specific to jobs for Rivanna is provided
[here](https://www.rc.virginia.edu/userinfo/rivanna/slurm/#gpu-intensive-computation).

Before we start an example, we explain how we create a job first in a
job description file and then submit it to Rivanna. We use a simple
MNIST example showcases the aspects of successfully running a job on
the machine. We will therefore focus on creating jobs using GPUs.

{{< alert color="warning" title="New 8  A100 GPUs to be added" >}}

Rivanna will have eight nodes available to us, but they are not yet in service.

Instead, we will be using the two existing nodes shared with other users.

{{< /alert >}}

Rivanna uses the SLURM job scheduler for allocating submitted jobs.
Jobs are charged SUs from an allocation. The Rivanna compute
allocation. Please contact your supervisor for the name of the allocation. Gregor's allocation is named

* `bii_dsc`

and it currently contains 100k SUs.  Students from the UVA capstone
class will have the following allocation:

* `ds6011-sp22-002`

To see the available SUs for your project, please use the command

* `allocations`
* `allocations -a <allocation_name>`

SUs can be requested via the [Standard Allocation Renewal
form](https://www.rc.virginia.edu/userinfo/rivanna/allocations/). Due
to the limitation, we encourage you to plan things and try to
avoid unnecessary runs. General instructions for submitting SLURM jobs
is located at

* <https://www.rc.virginia.edu/userinfo/rivanna/slurm/>

To request the job be submitted to the GPU partition, you use the option

`-p gpu`

The A100 GPUs are a requestable resource. To request them, you would
add the gres option with the number of A100 GPUs requested (1 through
8 GPUs), for example, to request 2 A100 GPUs,

`--gres=gpu:a100:2`. 
 
If you are using a SLURM script to submit the job the options
would appear as follows. Your script will need to specify other
options such as the allocation to charge as seen in the sample scripts
shown in the above URL:

```
#SBATCH -p gpu
#SBATCH --gres=gpu:a100:2
#SBATCH -A bii_dsc
```

### Interactive Jobs

Please avoid running interactive jobs as they may waste
SUs, and we are charged by you keeping the A100 idle.

Although Research Computing also offers some interactive apps such as
JupyterLab, RStudio, CodeServer, Blender, Mathematica via our Open
OnDemand portal at:

* <https://rivanna-portal.hpc.virginia.edu>

we ask you to avoid using them for benchmarks.

To request the use of the A100s via Open OnDemand, first log in to the
Open the OnDemand portal select the desired interactive app. You will be
presented with a form to complete. Currently, you would

* select `gpu` for Rivanna partition,
* select `NVIDIA A100` from the `Optional: GPU type for GPU partition`
  pulldown menu and enter the number of desired GPUs from the
  `Optional: Number of GPUs`. Once you've completed the form, click
  the `Launch` button and your session will be launched. The session
  will start once the resources are available.

### Using the MNIST example

For now, the code is located at:

* <https://github.com/laszewsk/mlcommons/tree/main/examples/mnist-tensorflow>

A sample slurm job specification is included at

* <https://github.com/laszewsk/mlcommons/blob/main/examples/mnist-tensorflow/mnist-rivanna-a100.slurm>

To run it use the command

```bash
$ sbatch mnist-rivanna-a100.slurm
```

NOTE: We want to improve the script to make sure it is running on a
GPU and add GPU placement commands into the code.

### Custom Version of TensorFlow

https://www.rc.virginia.edu/userinfo/rivanna/software/tensorflow/

### Keras on Rivanna

* https://www.rc.virginia.edu/userinfo/rivanna/software/keras/

## Building a Python verion from Source

{{< alert color="warning" title="Requirements" >}}
This section is under development
{{< /alert >}}



### Why do you wnat to do this?

### How is it been done?

Whe have developed the following script to create the enfironment on rivanna 
\url{httplatex ://example.com}

You can download the script from git with wget


```bash
wget ....
```

and place it in a driectory. running it with 

```bash
$ python-install.py --version="3.10.2" --host=rivanna
```

will create an optimized version for rivanna. Other options can be found with 
python-install.py help


### Where do you want to place it

scratch vs home dir

### How do you access it?

deployment into your own environment

### What is the performance gain?

benchmarks vs the various versions on python here. This needs to be reproducible when we have a new version of python

### How to cite if you use this

This work was conducted as part of the mlcommons science benchmark earthquake project and if youl ike to reuse it we like that you cite the following paper:


```
@TechReport{mlcommons-eartquake,
  author = 	 {Thomas Butler and Robert Knuuti and
              Jake Kolessar and Geoffrey C. Fox and
              Gregor von Laszewski and Judy Fox},
  title = 	 {MLCommons Earthquake Science Benchmark},
  institution =  {MLCommons Science Working Group},
  year = 	 2022,
  type = 	 {Report by University of Virginia},
  address = 	 {Charlottesville, VA},
  month = 	 may,
  note = 	 {The order of the authors and url location may change},
  annote = 	 {Version: draft},
  url = {https://github.com/cyberaide/paper-capstone-mlcommons}
}
```


