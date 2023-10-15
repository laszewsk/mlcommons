#!/bin/bash
#BSUB -W 1:59
#BSUB -nnodes 1
#BSUB -P GEN150_bench
#BSUB -o outputs-2/cloud_GPU_2.o%J.out
#BSUB -J cloudmask_GPU_2

# source $WORKDIR/ENV3/bin/activate

mkdir -p outputs-2

# Load modules
module purge
module load open-ce

# Install libraries
pip install scikit-learn
pip install h5py
pip install pyyaml
pip install cloudmesh-common
# pip install tensorflow

#This runs on many nodes
echo "Hostname: "
jsrun -n1 -r1 -c1 hostname
echo "Running slsts on GPU=2"
echo "***************************"

#jsrun  -n1 -a2 -r1 -c1 -g2 python slstr_cloud.py --config ./cloudMaskConfig_GPU_2.yaml
jsrun  -n1 -r1 -c1 -g2 python slstr_cloud.py --config ./cloudMaskConfig_GPU_2.yaml 
