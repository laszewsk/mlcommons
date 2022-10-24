echo "# cloudmesh status=running progress=1 pid=$$"

nvidia-smi --list-gpus

# conda install pip
echo "# cloudmesh status=running progress=20 pid=$$"
#conda install pytorch torchvision -c pytorch
#conda install py-cpuinfo
#conda install --file requirements.txt
echo "# cloudmesh status=running progress=40 pid=$$"
module load singularity tensorflow/2.8.0
module load cudatoolkit/11.0.3-py3.8
module load cuda/11.4.2
module load cudnn/8.2.4.15
module load anaconda/2020.11-py3.8
module load gcc

echo "# cloudmesh status=running progress=60 pid=$$"

cd /scratch/$USER/
git clone https://github.com/laszewsk/mlcommons.git
cd mlcommons/benchmarks/cloudmask/target/rivanna
git pull

if [ ! -d "/scratch/$USER/mlcommons/benchmarks/cloudmask/data" ]; then
  make data
fi

python setup_env_and_yaml.py
source activate MLBENCH
# conda activate MLBENCH

pip install tensorflow==2.8.0
pip install tensorflow-gpu==2.8.0
pip install scikit-learn
pip install h5py
pip install pyyaml

echo "# cloudmesh status=running progress=80 pid=$$"

mkdir -p ~/cm
cd ~/cm
pip install cloudmesh-installer -U
cloudmesh-installer get cc
git clone https://github.com/mlperf/logging.git mlperf-logging
pip install -e mlperf-logging

cms set host=rivanna
cms set cpu=IntelXeonE5-2630
cms set device=rivanna
echo "# cloudmesh status=running progress=100 pid=$$"