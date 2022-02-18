---
title: "Running MLCube on Rivanna"
linkTitle: "MLCube@Rivanna"
author: Grgeor von Laszewski, Robert Knuuti
date: 2022-02-06
weight: 4
description: >
  A gentle introduction to running MLCube on Rivanna
---

{{% pageinfo %}}

In this guide, we introduce MLCube and demonstrate how to run
workloads on Rivanna using the Singularity backend.

{{% /pageinfo %}}

Running models consistently across platforms requires users to have
commanding knowledge of the configuration of not only the source code,
but also of the hardware ecosystem.  It's not uncommon that you'll
encounter a project where configuring your system to get reproducible
results is error prone and time consuming, and ultimately not
productive to the analyst.

MLCube(tm) is a contract-driven approach to address system
configuration details and establishes a standard for generating
consistent models and a mechanism for delivering these models to
others, allowing others to benefit from having a solved environment.

## Getting Started

First you need to install a runner for MLCube.  The MLCube supports
many backend runners and should run on each of them equally.

For this walkthrough, we will target the Rivanna HPC ecosystem, so
we'll leverage the lmod and singularity ecosystems. 

## Python install

We have two
choices to install python. One is with pyenv, the other is with conda.

If you decide to install it with pyenv, use the following steps

```bash
pyenv install 3.9.7
pyenv global 3.9.7
python -m venv --prompt mlcube venv
source venv/bin/activate
python -m pip install mlcube-singularity
```

If you decide to install it with conda, use the following steps

```
conda create -n mlcube -c conda-forge python=3.9.7
conda activate mlcube
# We use pip as conda does not have an mlcube repository
python -m pip install mlcube-singularity
```

Note that the `mlcube-singularity` package can and should be installed
within your target environment.

## Using MLCube

Once you have run the above commands, you will now have the MLCube
script available on your path and you can now list what runners mlcube
has registered with

```bash
$ mlcube config --get runners
# System settings file path = /home/<username>/mlcube.yaml
# singularity:
#   pkg: mlcube_singularity
```

At this point you can run through any of the example projects that the
mlcube project hosts at
<https://github.com/mlcommons/mlcube_examples.git>.

Below is a set of procedures to run their hello world project.

```bash
git clone https://github.com/mlcommons/mlcube_examples.git
cd ./mlcube_examples/hello_world

mlcube run --mlcube=. --task=hello --platform=singularity
# No output expected.

mlcube run --mlcube=. --task=bye --platform=singularity
# No output expected.

cat ./workspace/chats/chat_with_alice.txt
# You should some log lines in this file.
```

## Nontrivial example - Earthquake Data

{{< alert color="information" title="Help wanted" >}}

We are looking to convert our earthquake model into an MLCube container.

{{< /alert >}}