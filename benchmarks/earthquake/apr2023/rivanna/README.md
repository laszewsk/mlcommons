# on rivanna
python -m venv ~/ENV3 # might be old version of python
# the point is to create a venv
source ~/ENV3/bin/activate
pip install cloudmesh-sbatch
cd /scratch/$USER/mlcommons/benchmarks/earthquake/apr2023/rivanna
make -f Makefile2 generate-singularity
sh jobs-singularity.sh 
