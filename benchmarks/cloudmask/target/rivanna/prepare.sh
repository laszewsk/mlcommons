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

# conda update -n base conda

echo "# cloudmesh status=running progress=60 pid=$$"

cd /scratch/$USER/
git clone https://github.com/laszewsk/mlcommons.git
cd mlcommons/benchmarks/cloudmask/target/rivanna
git pull

python setup_env_and_yaml.py
module load anaconda
conda init bash
source activate MLBENCH

if [ ! -d "/scratch/$USER/mlcommons/benchmarks/cloudmask/data" ]; then
  cd /scratch/$USER/mlcommons/benchmarks/cloudmask/ && \
mkdir -p data/ssts && mkdir -p data/one-day
  pip install awscli
	echo -n "Downloading first portion of data..." && \
cd /scratch/$USER/mlcommons/benchmarks/cloudmask/ && \
aws s3 --no-sign-request --endpoint-url https://s3.echo.stfc.ac.uk sync s3://sciml-datasets/es/cloud_slstr_ds1/one-day ./data/one-day --no-progress --cli-read-timeout 0 & process_id=$!
	wait $process_id
	echo -n "Downloading second portion of data..." && \
cd /scratch/$USER/mlcommons/benchmarks/cloudmask/ && \
aws s3 --no-sign-request --endpoint-url https://s3.echo.stfc.ac.uk sync s3://sciml-datasets/es/cloud_slstr_ds1/ssts ./data/ssts --no-progress --cli-read-timeout 0 & process_id_2=$!
	wait $process_id_2
fi

# conda activate MLBENCH

pip install tensorflow==2.8.0
pip install tensorflow-gpu==2.8.0
pip install scikit-learn
pip install h5py
pip install pyyaml

# conda install cudatoolkit -y

pip uninstall protobuf -y
pip install protobuf==3.19.4

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
echo "# cloudmesh status=done progress=100 pid=$$"