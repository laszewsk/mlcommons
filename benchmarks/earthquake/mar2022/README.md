# EQ Code

* Original code at <https://github.com/Data-ScienceHub/mlcommons-science/blob/main/code/earthquake/new/FFFFWNPFEARTHQ_newTFTv29.ipynb>
* Original data at ???

## Running the code

To run this code, you have two pathways:

1. Using the native python ecosystem via `pip`, or
2. Using the conda ecosystem.


## Non-interactive Process

1. Connect to UVA's VPN
2. SSH into rivanna by typing `ssh -Y <username>@rivanna.hpc.virginia.edu`, where `<username>` is your UVA Netbadge ID.
3. Checkout this mlcommons repo
   1. Using ssh (preferred): `git clone git@github.com:laszewsk/mlcommons.git`
   2. Using https (not recommended): `git clone https://github.com/laszewsk/mlcommons.git` 
   3. Note: If you've done this before, instead you should update your local copy using `git pull`
   4. Note: If you want to reset to the current latest and delete all local changes:  `git fetch origin && git checkout main && git reset --hard origin/main && git clean -d --force`
5. Navigate to the benchmark folder `cd mlcommons/benchmarks/earthquake/mar2022`
6. Schedule a task by running `sbatch rivanna-<type>.slurm`, where `<type>` is one of the graphics card partitions
   1. To check your job status, run `squeue --user $USER`.
8. If the job started successfully, your current working directory should have two log files that shows the progress.


## Interactive Process

### Starting a interactive session on Rivanna

1. Go to rivanna's OnDemand instance: <https://rivanna-portal.hpc.virginia.edu/pun/sys/dashboard/>
   1. You may need to login using your UVA credentials.
2. Click on "My Interactive Sessions"
3. Select "Interactive Apps",  "Desktops", "Desktop"
4. For your options, select
   1. Rivanna Partition: `GPU`
   2. Number of Hours: <time you plan to use the request>
   3. Number of Cores: `4` to `8`
   4. Memory: `32` to `64`
   5. Allocation: Use one of the following (depending on who you are)
      1. SDS Students: `ds6011-sp22-002`
      2. Others: `DSC_BII`
   6. GPU Type: Select any
      1. Note that `A100`s are limited, and `K80`s are plentiful.  You may get access faster if requesting K80s for development.
   7. Number of GPUs: `1-4`
   8. Slurm Options: Leave Blank
   9. Group: Use one of the following
      1. SDS Students: `ds6011-sp22-002`
      2. Others: `DSC_BII`
      
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
jupyter lab mar2022/FFFFWNPFEARTHQ_newTFTv29-gregor.ipynb
```

### Running the notebook non-interactively

First, consider running your workload using SLURM (see 

```bash
jupyter nbconvert --to notebook --execute feb-2022/FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb
```
   
#### Running using pip from the commandline

To preserver the original code, we first create a copy

```bash
cp mar2022/FFFFWNPFEARTHQ_newTFTv29.ipynb mar2022/FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb 
```

To run this code using pip, execute

```bash
jupyter nbconvert --to notebook --execute feb-2022/FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb
```

To see the output, you need to open the notebook.
   

## Running 


# Deprecated/Todo Instructions
   
## Building the container image

To build a container image of the entire benchmarking system (but not run the 
benchmark), you can run the commands

```bash
# If running docker
$ docker image build --tag mlcommons-science-earthquake:latest
# If running nerdctl
$ nerdctl image build --tag mlcommons-science-earthquake:latest
```
   
## Running on Rivanna

0. Activate the [UVA VPN](https://virginia.service-now.com/its/?id=itsweb_kb_article&sys_id=f24e5cdfdb3acb804f32fb671d9619d0)
1. Login to Rivanna

   ```bash
   ssh YOUR_UVA_ID@rivanna.rc.virginia.edu
   ```
   
2. Change to your scratch directory: 
   
   ```bash
   cd /scratch/$USER
   export SCRATCH=`cwd`
   ```   

3. Install a venv

   do this for whatever python version we need (maybe we need not to use default, 
   but special pythin version)
   
4. ```bash
   python -m venv $SCRATCH/ENV3   
   python should be in $SCRATCH/ENV3/bin/python
   ```

5. Install cloudmesh, if you have not yet done so (use either source or pip instalation)

   Source:

   ```bash
   pip install cloudmesh-installer
   cloudmesh-installer get data
   cms help
   ```


5. Run the following git commands to checkout the code and data

   TODO: use cms data 

   ```bash
   python install cloudmesh-data
   cms help
   git clone git@github.com:laszewsk/mlcommons-data-earthquake.git
   git clone git@github.com:laszewsk/mlcommons.git
   mkdir -p mlcommons/benchmarks/earthquake/feb-2022/data/Earthquake2020
   tar Jxvf mlcommons-data-earthquake/data.tar.xz --strip-components=1 -C mlcommons/benchmarks/earthquake/feb-2022/data/Earthquake2020`
   ```

   > **Note**: Be reminded to use the `cms help` command  once as it will create some 
   >configuration files in `~/.cloudmesh`. Without it, cloudmesh has limited 
   >capabilities and may not run properly.

   > **Note**: In case you like to also get the source code of cloudmesh, 
   > please replace the line `python install cloudmesh-data` with 
   >
   > ```bash
   > pip install cloudmesh-installer
   > cloudmesh-installer get data
   > ```
 
6. Activate cuda and cudnn capabilities

   ```bash
   module load cuda cudnn
   ```
   
7. Activate your ENV3 python and install all dependencies

   ```bash
   source /scratch/$SCRATCH/ENV3/bin/activate
   pip install -r requirements.txt
   ```

8. Navigate to the benchmark directory:
   
   ```bash
    cd mlcommons/benchmarks/earthquake/feb-2022
   ```
   
9. Copy the source notebook to your own version and run it

   ```bash
   cp FFFFWNPFEARTHQ_newTFTv29.ipynb FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb
   jupyter nbconvert --execute FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb --to notebook
   ```
   
## Configuration

Adjust the epochs to be lower for faster runs.

```
DLAnalysisOnly = False
DLRestorefromcheckpoint = False
DLinputRunName = RunName
DLinputCheckpointpostfix = ''

TFTTransformerepochs = 66
```



## Alternate Procedures

This is in work; recommend using the above procedure first.

### Running using Conda

To get this running with while using Conda, run

```bash
conda env create -f environment.yml
conda activatge mlcommons-science
jupytext --to py:percent FFFFWNPFEARTHQ_newTFTv29.ipynb
python FFFFWNPFEARTHQ_newTFTv29.py
```

Please note that we do not recommend that you use conda init, but instead activate 
the environment by hand. 

If you arre interested in doing interactive development, you can install the 
developer-focused modules by running

```bash
conda activate mlcommons-science
python -m pip install -rrequirements-dev.txt
jupyter lab .
```
