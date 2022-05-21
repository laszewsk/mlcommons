# CloudMask benchmark notes
Sea and land surface temperatures (or SST/LST), have a significant influence on the Earth’s weather. 
For instance, large variations of the SST in the Pacific can cause anything from severe drought, to 
heavy rainfall, to tropical cyclones. Estimation of Sea Surface Temperature (SST) from space-borne sensors, 
such as satellites, is crucial for a number of applications in environmental sciences. Satellites are often 
equipped with special sensors for this purpose, such as the Sea and Land Surface Temperature Radiometer on 
board the Sentinel-3 satellite, a mission operated jointly by the European Space Agency (ESA) and by the 
European Organisation for the Exploitation of Meteorological Satellites (EUMETSAT). It is possible to make 
direct measurements of surface temperature from these satellites everywhere, except when clouds are present. 
Clouds can really affect the signals measured by satellites so it is then much harder to retrieve the temperature 
measurements. One of the aspects that underpins the derivation of SST is cloud screening, which is a step that 
marks each pixel of thousands of satellite images as containing cloud or clear sky, historically performed using
either thresholding or Bayesian methods.

## Scientific Objective

The scientific objective is to develop a surrogate model for the classification of pixels in satellite images. 
This classification allows to determine whether the given pixel belongs to a cloud or to a clear sky. Unfortunately in 
this case the “true ground truth” was not available and for training we used the Bayesian masks which were supplied by 
the provider of satellite images. These masks are not always accurate, however the model has demonstrated that in some 
cases it can produce better predictions. The model is suitable for this type of task since it can achieve above 90% accuracy 
on the training and testing datasets. The next scientific objective is to avoid the use of Bayesian masks and make real 
cloudmask predictions by using unsupervised segmentation. Further objective of the benchmark is to achieve high accuracy 
on the given training and testing datasets, and to demonstrate the scalability of data parallel distributed training on multiple GPUs.

## Benchmark files

This is a standalone version of CloudMask benchmark intended as a reference 
implementation for MLCommons. The main program is slstr_cloud.py which reads 
cloudMaskConfig.yaml containing configuration details.

Files required for the CloudMask benchmark:
    slstr_cloud.py
    data_loader.py
    model.py
    cloudMaskConfig.yaml

## Data

The benchmark includes two datasets of cloud_slstr_ds1 and cloud_slstr_ds2, with sizes of 180GB and 4.9TB. 
Each dataset is made up of two parts: reflectance and brightness temperature. The reflectance is captured 
across six channels with the resolution of 2400 x 3000 pixels, and the brightness temperature is captured 
across three channels with the resolution of 1200 x 1500 pixels. The training directory contains files in the 
"one-day" folder, 163GB. The files used for inferencing with a size of 17GB in total are in "ssts" folder.
The dataset used in this benchmark is 180GB and can be odownloaded from the STFC server by using this command:

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








