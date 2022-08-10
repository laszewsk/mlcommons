
venv=ENV4

#
# eval `ssh-agent`
# ssh-add
#


#
# SETUP PYTHON
#
module load python/3.8-anaconda
conda create -yn ${venv} python=3.10
conda init bash
source ${HOME}/.bashrc
conda activate ${venv}
pip install pip -U
pip install cloudmesh-installer -U
mkdir ${HOME}/cm
cd ${HOME}/cm
cloudmesh-installer get sbatch

#
# CHEDKOUT laszewsk/mlcommons for requirements
#


git clone https://github.com/laszewsk/mlcommons.git ${HOME}/mlcommons
git clone https://github.com/laszewsk/mlcommons-data-earthquake.git ${HOME}/mlcommons-data-earthquake

cd ${HOME}/mlcommons/benchmarks/earthquake/latest
# pip install -r requirements.txt

which python
python -V 
