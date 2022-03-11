# Rivanna


Gregor will improve this with git clone form the repo

## Setting up Python 3.10 on rivanna

In your terminal you execute the following to simulate an environment that you will use 
on the compute nodes

```
module purge
module load singularity
module load anaconda

# conda create -y -n py3.10 python=3.10
#source activate py3.10
conda activate py3.10
python -V
PYTHON=`which python`
```

## Rivanna singuarity container

```
module load singularity
module avail tensorflow

mkdir -p /scratch/$USER/rivanna
cd /scratch/$USER/rivanna

export C=${CONTAINERDIR:-/share/resources/containers/singularity}
export U=$USER

cp $C/tensorflow-2.7.0.sif /scratch/$U/rivanna/
wget https://raw.githubusercontent.com/Data-ScienceHub/mlcommons-science/main/code/mnist-tensorflow/mnist.py
wget https://raw.githubusercontent.com/Data-ScienceHub/mlcommons-science/main/code/mnist-tensorflow/mnist-rivanna.slurm
wget https://raw.githubusercontent.com/laszewsk/mlcommons/main/examples/mnist-tensorflow/requirements.txt

conda create -y -n py3.10 python=3.10
source activate py3.10
python -m pip install -r requirements.txt

echo "Rivanna Frontend"
time singularity run --nv /scratch/$USER/rivanna/tensorflow-2.7.0.sif mnist.py
```

## Benchmarks

benchmarks may not be accurate, real time is what we probably want to focus on

| Machine     	    | real      | user      | sys       | Driver      | CUDA | GPU                   | CPU                                       | Date CPU released
|------------------|-----------|-----------|-----------| ----------- | ---- | ----                  |-------------------------------------------| ----
| Gregors Machine  | 0m11.534s | 0m13.914s | 0m05.186s | 510.47.03   | 11.6 | Gigabyte RTX3070 TI   | AMD 5950X                                 | Nov 2020
| Fox DGX          | 0m19.987s | 5m12.991s | 0m49.266s | 450.142.00  | 11.0 | NVIDIA A100 80GB      | AMD EPYC 7742 64-Core                     | Aug 2019
| Rivanna A100     | 0m29.263s | 0m14.585s | 0m7.399ss | 470.82.01   | 11.4 | NVIDIA A100-SXM4-40GB | Intel(R) Xeon(R) CPU E5-2630 v3 @ 2.40GHz | Q3  2014 
| MacBook Pro      | 0m31.01s  | 0m25.26s  | 130%      | N/A         | N/A  | N/A                   | M1 Max 66GB                               | Nov 2021
| Rivanna P100     | 0m35.732s | 0m17.253s | 0m7.595s  | 470.82.01   | 11.4 | Tesla P100-PCIE       | Intel(R) Xeon(R) CPU E5-2630 v3 @ 2.40GHz | Q3  2014 
| Rivanna V100     | 0m43.160s | 0m15.510s | 0m6.894s  | 470.82.01   | 11.4 | Tesla V100-SXM2       | Intel(R) Xeon(R) CPU E5-2630 v3 @ 2.40GHz | Q3  2014 
| Rivanna K80      | 0m57.588s | 0m20.322s | 0m9.612s  | 470.82.01   | 11.4 | NVIDIA TESLA K80      | Intel(R) Xeon(R) CPU E5-2630 v3 @ 2.40GHz | Q3  2014 
| Rivanna Frontend | 1m11.535s | 1m00.780s | 0m10.352s | N/A         | N/A  | N/A    		            | Intel(R) Xeon(R) CPU E5-2630 v3 @ 2.40GHz | Q3  2014 
| Robert Ryzen 9   | 0m19.274s | 0m00.000s | 0m00.031s | 511.23      | 11.6 | NVIDIA RTX 3080       | AMD Ryzen 9 (5900HX)                      | Q1  2021
| Thomas RTX 2070  | 0m3.387s  | 0m00.000s | 0m0.015s  | 511.79      | 11.6 | NVIDIA RTX 2070       | Intel Core i7-8750H                       | Q2  2018

## Tensorflow setup on M1

* <https://www.mrdbourke.com/setup-apple-m1-pro-and-m1-max-for-machine-learning-and-data-science/>
