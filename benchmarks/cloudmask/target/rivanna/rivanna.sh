#!/bin/sh
#SBATCH --job-name=cloudmask-%j
#SBATCH --output=cloudmask-%j.log
#SBATCH --error=cloudmask-%j.error
#SBATCH --partition=gpu
#SBATCH --cpus-per-task=1
#SBATCH --mem=64GB
#SBATCH --time=59:00

## to run this say sbatch rivanna.sh

echo "# cloudmesh status=running progress=1 pid=$$"

#cd /project/bii_dsc/cloudmask/science/benchmarks/cloudmask

currentgpu=$(echo $(cms set currentgpu) | sed -e "s/['\"]//g" -e "s/^\(currentgpu=\)*//")
currentepoch=$(echo $(cms set currentepoch) | sed -e "s/['\"]//g" -e "s/^\(currentepoch=\)*//")

#python run_all_rivanna.py
cd /scratch/$USER/mlcommons/benchmarks/cloudmask
python slstr_cloud.py --config ./cloudMaskConfig.yaml > output_$(echo $currentgpu)_$(echo $currentepoch).log 2>&1
#python mnist_with_pytorch.py > mnist_with_pytorch_py_$(echo $currentgpu).log 2>&1
echo "# cloudmesh status=done progress=100 pid=$$"
# python mlp_mnist.py
