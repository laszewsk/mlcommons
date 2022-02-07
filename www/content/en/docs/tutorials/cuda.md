---
title: "Installing nvcc on Uuntu 20.04"
linkTitle: "Install nvcc"
author: Grgeor von Laszewski
date: 2017-01-05
weight: 4
description: >
  A description on how to install nvcc in cuda
---

{{% pageinfo %}}
  A description on how to install nvcc in cuda
{{% /pageinfo %}}


{{< alert color="warning" title="Requirements" >}}
Draft
{{< /alert >}}


## Instalation

```bash
$ sudo wget -O /etc/apt/preferences.d/cuda-repository-pin-600 https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
$ sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub
$ sudo add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
$ sudo apt update
$ sudo apt install cuda
```

Add it to your path

```bash
$ echo 'export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}' >> ~/.bashrc
```

Check CUDA version:

```bash
$ nvcc --version
```

```
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2019 NVIDIA Corporation
Built on Wed_Oct_23_19:24:38_PDT_2019
Cuda compilation tools, release 10.2, V10.2.89
```