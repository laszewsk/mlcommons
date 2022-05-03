# EQ Code

## Versions


v 1.2.2

* cloudmesh-sbatch has been tag eq1.2.2

v 1.2.1


* https://github.com/cloudmesh/cloudmesh-sbatch/pull/4

* spawned 72 jobs in sbatch from each of these scripts without rivanna
  applying a limiting quota to me, and 32 of them are executing
  concurrently (however there is still some things to work out, as
  there's concurrent access issues still), so this reenforces the lack
  of a maximum number of jobs you can request (although it looks like
  it did queue me after 32 (but this may be due to the lack of
  resources, the full spawning does ask for roughly 6 TBs of memory in
  32GB and 64GB chunks), so we may want to split things up or start to
  iron out what permutations are meaningful.

* Possible concurrency issues in the slurm script I've been using (the
  lock files for git do not appear to be working properly (some
  commands are going too fast and git "thinks" that it's not a
  repository), and there's errors in creating temp files), so there's
  some improvements to be done there.

* An easy fix for this is to switch back to having all files be
  isolated in each job, but this reintroduces the file handle
  reduction I worked in previously (but maybe this doesn't matter
  anymore if we're not planning on running anything from /scratch.


v1.1 - before integration of pull request 4



v 1.0



* Original code at <https://github.com/Data-ScienceHub/mlcommons-science/blob/main/code/earthquake/new/FFFFWNPFEARTHQ_newTFTv29.ipynb>
* Original data at 

## Benchmark Results

### Two Epoch Case


| Timer                        | Status  | K80(r)    | V100(r)    | A100(r)  | RTX3090(G) | RTX3080(R) | T1(?)   | V100(L) |
|------------------------------|---------|-----------|------------|----------|------------|------------|---------|---------|
| total                        |  ok     |  28343.3  |   20295    |  17574.8 |   6589.41  |    8348.49 | 17580.4 | 19697.1 |
| legal sampling location      |  ok     |   1779.63 |   1546.38  |  1226.95 |   457.886  |    532.535 | 1228.35 | 1229.91 |
| RunTFTCustomVersion tft only |  ok     |     0.001 |     0.001  |    0.001 |       0    |        0   | 0.001   | 0.001   |
| RunTFTCustomVersion init     |  ok     |     5.327 |     5.624  |    8.078 |      0.84  |     3.612  | 4.163   | 3.548   |
| RunTFTCustomVersion train    |  ok     |   6967.26 |    1671.35 |  1373.01 |   1103.15  |    2068.9  | 1342.07 | 1608.61 |
| RunTFTCustomVersion bestfit  |  ok     |   17037.6 |    14795.1 |  13022.1 |   4420.31  |    4997.13 | 13018.4 | 14303.7 |
| label2                       |  ok     |     0.002 |      0.002 |    0.002 |      0.001 |      0.001 | 0.002   | 0.002   |
| label3                       |  ok     |     0.108 |     0.096  |    0.099 |     0.033  |      0.036 | 0.1     | 0.01    |
 
G = Gregor
R = Robert
r = RIvanna
T1 = Thomas posted something incomplete post so we do not know what it is https://spring22ds6011002.slack.com/archives/C038HBX9FME/p1649616003897029
L = 2 epoch bii=gpu localscratch https://spring22ds6011002.slack.com/archives/C038HBX9FME/p1650019967536729

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
