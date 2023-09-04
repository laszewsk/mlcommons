Setting up Singularity
-1. export $PROJECT_DIR=/scratch/$USER/github/mlcommons/benchmarks/cloudmask/target/rivanna_tmp
0. 
   mkdir /scratch/$USER/github/
   cd /scratch/$USER/github/
   
1. git clone https://github.com/laszewsk/mlcommons.git
   cp -r mlcommons/benchmarks/cloudmask/target/rivanna/image-singularity mlcommons/benchmarks/cloudmask/target/rivanna_tmp/image-singularity

2. cd mlcommons/benchmarks/cloudmask/target/rivanna_tmp/image-singularity
3. singularity pull docker://nvcr.io/nvidia/tensorflow:22.10-tf2-py3
4. cp tensorflow_22.10-tf2-py3.sif cloudmask.sif

4*. cp -rp /scratch/work/public/overlay-fs-ext3/overlay-15GB-500K.ext3.gz .
gunzip overlay-15GB-500K.ext3.gz


5. singularity exec --overlay overlay-15GB-500K.ext3:rw cloudmask.sif /bin/bash
unset -f which
# source /ext3/env.sh
which python
which pip
python --version


6. Singuarity > 
=====
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
    
=====

8. shell script (to set up singularity)