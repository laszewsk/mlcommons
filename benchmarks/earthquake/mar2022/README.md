# EQ Code

* Original code at <https://github.com/Data-ScienceHub/mlcommons-science/blob/main/code/earthquake/new/FFFFWNPFEARTHQ_newTFTv29.ipynb>
* Original data at ???

## Benchmark Results

### Two Epoch Case


| Timer                        | Status  | K80(r)    | V100(r)    | A100(r)  | RTX3090(G) | RTX3080(R) |
|------------------------------|---------|-----------|------------|----------|------------|------------|
| total                        |  ok     |  28343.3  |   20295    |  17574.8 |   6589.41  |    8348.49 |
| data head setup              |  failed |           |            |          |            |            |
| legal sampling location      |  ok     |   1779.63 |   1546.38  |  1226.95 |   457.886  |    532.535 |
| RunTFTCustomVersion tft only |  ok     |     0.001 |     0.001  |    0.001 |       0    |        0   |
| RunTFTCustomVersion print    |  failed |           |            |          |            |            |
| RunTFTCustomVersion init     |  ok     |     5.327 |     5.624  |    8.078 |      0.84  |     3.612  |
| RunTFTCustomVersion restore  |  ok     |        0  |        0   |        0 |         0  |          0 |
| RunTFTCustomVersion analysis |  ok     |        0  |        0   |        0 |         0  |          0 |
| RunTFTCustomVersion train    |  ok     |   6967.26 |    1671.35 |  1373.01 |   1103.15  |    2068.9  |
| RunTFTCustomVersion bestfit  |  ok     |   17037.6 |    14795.1 |  13022.1 |   4420.31  |    4997.13 |
| label1                       |  ok     |        0  |        0   |       0  |       0    |        0   |
| label2                       |  ok     |     0.002 |      0.002 |    0.002 |      0.001 |      0.001 |
| label3                       |  ok     |     0.108 |     0.096  |    0.099 |     0.033  |      0.036 |
| RunTFTCustomVersion stop     | failed  |           |            |          |            |            |
 
G = Gregor
R = Robert
r = RIvanna
 
## Running the code

To run this code, you have two pathways:

1. Using the native python ecosystem via `pip`, or
2. Using the conda ecosystem.


## Non-interactive Process

1. Connect to [UVA VPN](https://virginia.service-now.com/its/?id=itsweb_kb_article&sys_id=f24e5cdfdb3acb804f32fb671d9619d0)
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
cp mar2022/FFFFWNPFEARTHQ_newTFTv29-gregor.ipynb mar2022/FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb
jupyter lab mar2022/FFFFWNPFEARTHQ_newTFTv29-gregor.ipynb
```

### Running the notebook non-interactively

First, consider running your workload using SLURM (see 

```bash
cp mar2022/FFFFWNPFEARTHQ_newTFTv29-gregor.ipynb mar2022/FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb
jupyter nbconvert --to notebook --execute feb-2022/FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb
```
   
### Configuration
   
Some useful reconfiguration of the notebook files that help during development

#### Lowering the epoch count
   
This will make for faster runs, but will lower the overall performance of the model.

```
DLAnalysisOnly = False
DLRestorefromcheckpoint = False
DLinputRunName = RunName
DLinputCheckpointpostfix = ''

TFTTransformerepochs = 66
```
   
### Running using pip from the commandline

To preserver the original code, we first create a copy

```bash
cp mar2022/FFFFWNPFEARTHQ_newTFTv29.ipynb mar2022/FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb 
```

To run this code using pip, execute

```bash
jupyter nbconvert --to notebook --execute feb-2022/FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb
```

To see the output, you need to open the notebook.
   

# Running the code on Google Colab
   
Open Google Colab and select Github
   
Search for https://github.com/laszewsk/mlcommons
   
Select the latest notebook *
   
Open the runtime terminal
   
Make the dataset directory 
   
```bash
cd /content/gdrive/My Drive
mkdir Colab\ Datasets/
```
Make a copy of the data
  
```bash
cd /content/gdrive/MyDrive/Colab\ Datasets/
git clone https://github.com/laszewsk/mlcommons-data-earthquake.git mlcommons-data-earthquake
tar Jxvf mlcommons-data-earthquake/data.tar.xz -C .
```
From the 'Runtime' dropdown menu select 'Run all'
   
When promted, approve the notebook to access your Google Drive

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
