# UNO

- [x] Using rclone to download data
Cannot run on front load noad
Download data to uno directory within scratch directory 
rivanna:/scratch/uno/data
Create backup copy rivanna:/project/bii_dsc_community/data/uno
Documentation for rclone on informal/rivanna
Download code (to particular directory within rivanna below)
rivanna:/project/bii_dsc_community/esf3xw/uno
export DATA_DIR=/project/bii_dsc_community/data/uno
export PROJECT_DIR=/project/bii_dsc_community/esf3xw/uno
**Telling slurm where to look for the code and data**
Locate the repository for UNO (final production do not use!!!)
https://github.com/mlcommons/science/tree/main/benchmarks/uno
Development Repo

```bash
rivanna>	
  cd $PROJECT_DIR
  git clone https://github.com/laszewsk/mlcommons/tree/main/benchmarks/uno
```

Figure out from the original Readme how to run code.
Learn how to run an interactive node on the Rivanna system
Wget	http://ftp.mcs.anl.gov/pub/candle/public/benchmarks/Pilot1/uno/top_21_auc_1fold.uno.h5
Use on Rivanna's head node. Biihead2
Use Greene file 
$USER_SCRATCH → figure this out
rivanna:/scratch/esf3xw
export USER_SCRATCH=/scratch/$USER
use similar to https://github.com/laszewsk/mlcommons/blob/main/benchmarks/cloudmask/experiments/greene/README.md#installing-python
Create a simple.slurm
https://github.com/laszewsk/mlcommons/blob/main/benchmarks/cloudmask/experiments/greene/simple.slurm


**How to download document data using ftp server
To know if download succeeds,
Ftp file has a particular length in bites, make sure its the same
Uncompress download
Look at file to see if it was correct
create /data directory in project directory to store to
LOOK at Cloudmesh common on github *flatdeck
Example program for this, as well as how to install cloud mesh on discord
LOOK read about not using home directory on informal IMPORTANT






Notes:
No access to headnode, just manages program called slurm
Slurm has worker nodes as well, this is where I execute my computations (think like a cloud)
These nodes are only available in an offline queue
Interactive nodes are for testing, documentation for srun is this
Four repositories we work with
Do not do anything on the front end node!!!!
Meaning run on biihead2, like installation etc.
Logout of node, Mr. Fox gets charged 🙁

EXTREMELY IMPORTANT
Everytime I start working sync with repository “laszewsk” (just go to github and press sync)
Git pull of my own repository
Set up Python:
node> 
  module purge
  module load anaconda3/2020.07
  module load cudnn/8.6.0.163-cuda11
  conda create -p $USER_SCRATCH/python310 python=3.10
  conda activate $USER_SCRATCH/python310
  python3 -m venv $USER_SCRATCH/ENV3
  conda deactivate
  source $USER_SCRATCH/ENV3/bin/activate
  pip install pip -U
  which python
  python --version







