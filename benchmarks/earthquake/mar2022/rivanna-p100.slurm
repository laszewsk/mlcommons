#!/usr/bin/env bash
#SBATCH --job-name=mlcommons-science-earthquake
#SBATCH --output=mlcommons-science-earthquake.out
#SBATCH --error=mlcommons-science-earthquake.err
#SBATCH --partition=gpu
#SBATCH -c 1
#SBATCH --time=00:10:00
#SBATCH --gres=gpu:k80:1
#SBATCH --account=bii_dsc



BASE=/scratch/$USER
HOME=${BASE}

cd ${BASE}

if [ ! -e "${BASE}/.local/python/3.10.2" ] ; then
    tar Jxvf /project/ds6011-sp22-002/python-3.10.2.tar.xz -C "${BASE}"
fi

export LD_LIBRARY_PATH=${BASE}/.local/ssl/lib:$LD_LIBRARY_PATH
echo "Python setup"

if [ ! -e "${BASE}/ENV3/bin/activate" ]; then
    ${BASE}/.local/python/3.10.2/bin/python3.10 -m venv ${BASE}/ENV3
fi

echo "ENV3 Setup"
source ${BASE}/ENV3/bin/activate
python -m pip install -U pip wheel

if [ ! -e "${BASE}/cm" ]; then
    python -m pip install cloudmesh-installer
    mkdir -p cm
    (cd cm && cloudmesh-installer get cms)
fi

if [ ! -e "${HOME}/.cloudmesh" ]; then
  cms help
fi

echo "Cloudmesh setup"

if [ ! -e mlcommons-earthquake-data ]; then
    git clone https://github.com/laszewsk/mlcommons-data-earthquake.git
fi

if [ ! -e mlcommons ]; then
    git clone https://github.com/laszewsk/mlcommons.git
else
    git pull
fi

if [ ! -e ${BASE}/mlcommons/benchmarks/earthquake/feb-2022/data/Earthquake2020 ]; then
    mkdir -p ${BASE}/mlcommons/benchmarks/earthquake/feb-2022/data/Earthquake2020
    tar Jxvf ${BASE}/mlcommons-data-earthquake/data.tar.xz --strip-components=1 -C ${BASE}/mlcommons/benchmarks/earthquake/feb-2022/data/Earthquake2020
fi


(cd mlcommons/benchmarks/earthquake/feb-2022 && \
    python -m pip install -r requirements.txt)


module load cuda cudnn

(cd mlcommons/benchmarks/earthquake/feb-2022 && cp FFFFWNPFEARTHQ_newTFTv29.ipynb FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb)
(cd mlcommons/benchmarks/earthquake/feb-2022 && jupyter nbconvert --execute FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb --to notebook)