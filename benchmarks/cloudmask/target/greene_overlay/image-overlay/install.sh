#!/bin/sh

pip install pip -U ; python --version
pip install scikit-learn
# pip install aws-cli

# install from requirements file in rivanna folder
# pip install protobuf==3.20.0 numpy tensorflow

pip install h5py
pip install pyyaml
pip install git+https://github.com/mlperf/logging.git@1.0.0

pip install cloudmesh-common
pip install cloudmesh-gpu
pip install cloudmesh-sbatch
