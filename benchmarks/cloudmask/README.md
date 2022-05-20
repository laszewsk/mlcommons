# CloudMask benchmark notes

This is a standalone version of CloudMask benchmark intended as a reference 
implementation for MLCommons. The main program is slstr_cloud.py which reads 
cloudMaskConfig.yaml containing configuration details.

## Benchmark files

Files required for the CloudMask benchmark:
    slstr_cloud.py
    data_loader.py
    model.py
    cloudMaskConfig.yaml

## Data

The dataset is 180GB and it take a while until it downloads. 
The datast can be odownloaded from the STFC server by using this command.


The training directory contains files in the "one-day" folder, 163GB. The files used for inferencing with a size of 17GB in total are in "ssts" folder.


## Installation

It is recommended to run the CloudMask benchmark in the Anaconda environment where 
the required packages can be easily installed and the versioning of libraries can be maintained. For the installation use these sequence of instructions:

1. If Anaconda is not already installed on the system, it can be downloaded from here:
   `wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh`

2. Install Anaconda
   `bash Anaconda3-2021.05-Linux-x86_64.sh`

3. Create conda environment
   `conda create --name bench python=3.8`

4. `conda activate bench`

5. `pip install tensorflow`

6. `pip install scikit-learn`

7. `pip install h5py`

8. Running the benchmark
   `python slstr_cloud.py`

## Running the benchmark

`python slstr_cloud.py --config ./cloudMaskConfig.yaml`

## Multiple GPUs

TensorFlow automatically detects the available GPUs and runs the application in a data parallel mode.








