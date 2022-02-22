---
title: "Setting up Environment from Scratch"
linkTitle: "Install python and setup"
author: Robert Knuuti
date: 2022-02-21
weight: 4
description: >
  A procedure to build an optimized python from source and setup a development environment to run benchmarks.
---

{{% pageinfo %}}
  A description on how to install nvcc in cuda
{{% /pageinfo %}}


{{< alert color="warning" title="Requirements" >}}
Draft
{{< /alert >}}


## Introduction

Most modern linux systems come prepackaged with a version of Python 3.
However, this version is typically deeply integrated into the operating system's ecosystem of tools, so it may be a significantly older version of python and it may lack some optimizations to maximize compatibility.

For benchmarking, it is desireable to have control over your source program, so that running programs are both consistent and repeatable.
Below are the steps to build Python 3.10.2 on a variety of hosts.

## Setup

### Configurations

This procedure assumes the following:

1. You are building using `bash`
2. You have `curl`, `make`, `gcc`, `openssl`, `bzip2`, `libffi`, '`zlib`, `readline`, `sqlite3`, `llvm`, `ncurses`, and `xz` c header files installed.
3. You have set the following environment variables
   1. `BASE` - Specifies the working directory for all operations.  This procedure assumes `~/.local`
   2. `PREFIX` - Where you want the final python instance to be positioned.  This procedure assumes `${BASE}/python/3.10.2`.

### Build OpenSSL

```bash
# Fetch source code
curl -OL https://www.openssl.org/source/openssl-1.1.1m.tar.gz
tar -zxvf openssl-1.1.1m.tar.gz -C ${BASE}/src/
cd ${BASE}/src/openssl-1.1.1m/
./config --prefix=${BASE}/ssl --openssldir=${BASE}/ssl shared zlib
make
#make test
make instal
make clean
```

### Build Python

```bash
curl -OL https://www.python.org/ftp/python/3.10.2/Python-3.10.2.tar.xz
tar Jxvf Python-3.10.2.tar.xz -C ${BASE}/src/
cd Python-3.10.2
export CPPFLAGS=" -I${BASE}/ssl/include "
export LDFLAGS=" -L${BASE}/ssl/lib "
export LD_LIBRARY_PATH=${BASE}/ssl/lib:$LD_LIBRARY_PATH
./configure --prefix=${PREFIX} --enable-optimizations --with-lto --with-computed-gotos --with-system-ffi

make -j "$(nproc)"
make test
make altinstall
make clean

mkdir -p ${BASE}/.local/bin
(cd ${BASE}/bin ; ln -s python3.10 python)

cat <<EOF > ${BASE}/setup.source
#!/bin/bash

BASE=$BASE
PREFIX=$PREFIX

export LD_LIBRARY_PATH=\$BASE/ssl/lib:\$PREFIX/lib:\$LD_LIBRARY_PATH
export PATH=\$PREFIX/bin:\$PATH
EOF
```

### Archive Build

```bash
tar Jxvf python-3.10.2.tar .xz $BASE
```

## Common Setup Procedures

To bootstrap your new environment with all the tools frequently leveraged during development, see the below procedures.

Assumption: The variable `BASE` is your user home directory, and python3.10 is on the path.

```bash
mkdir -p ${BASE}/ENV3
python3.10 -m venv --prompt ENV3 ~/ENV3

source ${BASE}/ENV3/bin/activate
pip install -U pip
pip install cloudmesh-installer

mkdir -p ~/git/cm
(cd ~/git/cm && cloudmesh-installer get cms)

echo "alias ENV3=\"source $BASE/ENV3/bin/activate\"" >> ~/.bash_profile
echo "alias EQ=\"cd $BASE/git\"" >> ~/.bash_profile
source ~/.bash_profile

EQ

git clone git@github.com:laszewsk/mlcommons.git
git clone git@github.com:laszewsk/mlcommons-data-earthquake.git

pip install -r mlcommons/examples/mnist-tensorflow/requirements.txt
pip install -r mlcommons/benchmarks/earthquake/new/requirements.txt
```
