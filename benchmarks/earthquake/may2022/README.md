# Earthquake code

This is the Earthquake Benchmark For MLCommons.

Original code at <https://github.com/Data-ScienceHub/mlcommons-science/blob/main/code/earthquake/new/FFFFWNPFEARTHQ_newTFTv29.ipynb>

## Run on arbitrary system

Note: This is a guideline and your system might need to run code differently to run the notebook.

Assumes Python 3.9 or above and cloudmesh-sbatch

Install cloudmesh sbatch

```bash
python3.10 -m venv ~/ENV3
source ~/ENV3/bin/activate
mkdir ~/cm
cd ~/cm
pip install cloudmesh-installer
cloudmesh-installer get sbatch
```

### Get the Code and Data

```bash
# If doing updates, advise using ssh commands.
#git clone git@github.com:laszewsk/mlcommons.git
#git clone git@github.com:laszewsk/mlcommons-data-earthquake.git

# If just trying to run as a one-off
git clone https://github.com/laszewsk/mlcommons.git
git clone https://github.com/laszewsk/mlcommons-data-earthquake.git
export EQ="$(pwd)/mlcommons/benchmarks/earthquake"
tar xvf mlcommons-data-earthquake/data.tar.xz -C "$EQ"
cd "$EQ"
module load anaconda
python -m venv --prompt mlcommons-science venv
source venv/bin/activate # or .\venv\Scripts\activate.bat on windows
python -m pip install -r "mar2022/requirements.txt"
module load cuda cudnn
```

this will create all data files necessary to run the notebook.

### Running notebook interactively

```bash
cp mar2022/FFFFWNPFEARTHQ_newTFTv29-gregor.ipynb mar2022/FFFFWNPFEARTHQ_newTFTv29-copy.ipynb
jupyter lab mar2022/FFFFWNPFEARTHQ_newTFTv29-gregor.ipynb
```

## Hyperparameters with sbatch

Hyperparameters are stored on yaml files in each implementation. If the hyperparameters need to be changed, the yaml file holds all the hyperparameters.

## Rivanna

The code can be run on UVA's (University of Virginia) computing cluster Rivanna.

## Running the code

1. Connect to [UVA VPN](https://virginia.service-now.com/its/?id=itsweb_kb_article&sys_id=f24e5cdfdb3acb804f32fb671d9619d0)
2. SSH into rivanna by typing `ssh -Y <username>@rivanna.hpc.virginia.edu`, where `<username>` is your UVA Netbadge ID.
3. Follow instructions [here](experiments/rivanna/README.md)


## Rivanna 2-epoch test case

1. Connect to [UVA VPN](https://virginia.service-now.com/its/?id=itsweb_kb_article&sys_id=f24e5cdfdb3acb804f32fb671d9619d0)
2. SSH into rivanna by typing `ssh -Y <username>@rivanna.hpc.virginia.edu`, where `<username>` is your UVA Netbadge ID.
3. Follow instructions [here](experiments/rivanna-2epoch/README.md)


## Ubuntu Slurm

Please follow instructions [here](experiments/ubuntu-slurm/README.md)


## Colab

Please follow instructions [here](experiments/colab/README.md) Note: currently work in progress
