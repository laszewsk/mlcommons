# Rivanna


Gregor will improve this with git clone form the repo

## Rivanna singuarity container

```
module load singularity
module avail tensorflow

mkdir -p /scratch/$USER/rivann
cd /scratch/$USER/rivanna

export C=$CONTAINERDIR
export U=$USER

cp $C/tensorflow-2.7.0.sif /scratch/$U/rivanna/
wget https://raw.githubusercontent.com/Data-ScienceHub/mlcommons-science/main/code/mnist-tensorflow/mnist.py
wget https://raw.githubusercontent.com/Data-ScienceHub/mlcommons-science/main/code/mnist-tensorflow/mnist-rivanna.slurm

echo "Rivanna Frontend"
time singularity run --nv /scratch/$USER/rivanna/tensorflow-2.7.0.sif mnist.py
```

## Benchmarks

benchmarks may not be accurate, real time is what we probably want to focus on

| Machine     	    | real      | user      | sys        | Driver      | CUDA | GPU                   | CPU                                        | Date CPU released
| ----------------- | --------- | --------- | ---------- | ----------- | ---- | ----                  | ----                                       | ----
| Gregors Machine   | 0m11.534s | 0m13.914s | 0m05.186s  | 510.47.03   | 11.6 | Gigabyte RTX3070 TI   | AMD 5950X                                  | Nov 2020
| Fox DGX           | 0m19.987s | 5m12.991s | 0m49.266s  | 450.142.00  | 11.0 | NVIDIA A100 80GB      | AMD EPYC 7742 64-Core                      | Aug 2019
| Rivanna A100      | 0m29.263s | 0m14.585s | 0m7.399ss  | 470.82.01   | 11.4 | NVIDIA A100-SXM4-40GB | Intel(R) Xeon(R) CPU E5-2630 v3 @ 2.40GHz  | Q3  2014 
| MacBook Pro       | 0m31.01s  | 0m25.26s  | 130%       | N/A         | N/A  | N/A                   | M1 Max 66GB                                | Nov 2021
| Rivanna P100      | 0m35.732s | 0m17.253s | 0m7.595s   | 470.82.01   | 11.4 | Tesla P100-PCIE       | Intel(R) Xeon(R) CPU E5-2630 v3 @ 2.40GHz  | Q3  2014 
| Rivanna V100      | 0m43.160s | 0m15.510s | 0m6.894s   | 470.82.01   | 11.4 | Tesla V100-SXM2       | Intel(R) Xeon(R) CPU E5-2630 v3 @ 2.40GHz  | Q3  2014 
| Rivanna K80       | 0m57.588s | 0m20.322s | 0m9.612s   | 470.82.01   | 11.4 | NVIDIA TESLA K80      | Intel(R) Xeon(R) CPU E5-2630 v3 @ 2.40GHz  | Q3  2014 
| Rivanna Frontend  | 1m11.535s | 1m00.780s | 0m10.352s  | N/A         | N/A  | N/A    		      | Intel(R) Xeon(R) CPU E5-2630 v3 @ 2.40GHz  | Q3  2014 


## Tensorflow setup on M1

* <https://www.mrdbourke.com/setup-apple-m1-pro-and-m1-max-for-machine-learning-and-data-science/>
