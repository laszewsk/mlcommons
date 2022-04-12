#!/bin/bash
#BSUB -P GEN150_bench
#BSUB -W 00:5
#BSUB -nnodes 1
#BSUB -J mnist-tensorflow
#BSUB -o mnist-tensorflow.%J.out
#BSUB -e mnist-tensorflow.%J.err

cd $LSB_OUTDIR
date


module load open-ce/1.5.2-py39-0
which python
python --version
python -c 'import tensorflow as tf; print(tf.__version__)'

lscpu

nvidia-smi

pip install cloudmesh-common -U

time python mnist-gpu.py
