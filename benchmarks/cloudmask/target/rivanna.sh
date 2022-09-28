#!/bin/sh
#SBATCH --job-name=cloudmask-%j
#SBATCH --output=cloudmask-%j.log
#SBATCH --error=cloudmask-%j.error
#SBATCH --partition=gpu
#SBATCH --cpus-per-task=1
#SBATCH --mem=32GB
#SBATCH --time=59:00
#SBATCH --gres=gpu:a100:1

## to run this say sbatch rivanna.sh

echo "# cloudmesh status=running progress=1 pid=$$"

nvidia-smi --list-gpus

# conda install pip
echo "# cloudmesh status=running progress=50 pid=$$"
#conda install pytorch torchvision -c pytorch
#conda install py-cpuinfo
#conda install --file requirements.txt
echo "# cloudmesh status=running progress=60 pid=$$"
module load singularity tensorflow/2.8.0
module load cudatoolkit/11.0.3-py3.8
module load cuda/11.4.2
module load cudnn/8.2.4.15
module load anaconda/2020.11-py3.8

cd /scratch/$(echo $USER)/
git clone https://github.com/laszewsk/mlcommons.git
cd mlcommons/benchmarks/cloudmask
git pull

python create_python.py
source activate MLBENCH
# conda activate MLBENCH

pip install tensorflow-gpu
pip install scikit-learn
pip install h5py
pip install pyyaml

mkdir -p ~/cm
cd ~/cm
pip install cloudmesh-installer -U
cloudmesh-installer get cc

cms set host=rivanna
cms set cpu=IntelXeonE5-2630
cms set device=rivanna
echo "# cloudmesh status=running progress=70 pid=$$"


#cd /project/bii_dsc/cloudmask/science/benchmarks/cloudmask



#currentgpu=$(echo $(cms set currentgpu) | sed -e "s/['\"]//g" -e "s/^\(currentgpu=\)*//")
#currentgpu=a100

#python run_all_rivanna.py
cd /scratch/$(echo $USER)/mlcommons/benchmarks/cloudmask
python slstr_cloud.py --config ./cloudMaskConfig.yaml > output.log 2>&1
#python mnist_with_pytorch.py > mnist_with_pytorch_py_$(echo $currentgpu).log 2>&1
echo "# cloudmesh status=done progress=100 pid=$$"
# python mlp_mnist.py
