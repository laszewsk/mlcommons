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
pip install cloudmesh-sbatch
cms help
cd /scratch/$USER/mlcommons/benchmarks/earthquake/apr2023/rivanna
make generate-singularity
```


```bash
sh jobs-singularity.sh 
```