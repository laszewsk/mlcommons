## Build Image

```
make image
```

## ENV3

```bash
module purge
module load gcc/11.2 openmpi/4.1.4 python/3.11.1
which python
python --version
python -m venv /scratch/$USER/EQ
source /scratch/$USER/EQ/bin/activate
pip install cloudmesh-ee
pip install cloudmesh-rivanna
cms help
cd /scratch/$USER/mlcommons/benchmarks/earthquake/apr2023/rivanna
make generate-singularity
```

## Download Data

```bash
cd /scratch/$USER/
git clone https://github.com/laszewsk/mlcommons-data-earthquake.git neweqdata
tar -xvzf fixed-data.tar.gz
```


## Run


```bash
sh jobs-singularity.sh 
```