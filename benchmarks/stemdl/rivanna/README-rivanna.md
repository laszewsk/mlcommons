# STEMDL classification benchmark



# Initial Setup

In order to properly run program we must first set up a virtual environment 

Set Python version to python3
```bash
alias python='python3'
```
Activate ENV3 
```bash
python -m venv /scratch/$USER/ENV3
```
```bash
source /scratch/$USER/ENV3/bin/activate 
```
Ensure latest version of pip
```bash
pip install pip -U
```

Declare the export variables here 

```bash
export SINGULARITY_CACHE=/scratch/$USER/.singularity/cache
mkdir -p $SINGULARITY_CACHE
```

Download Data in correct directory

Create singlaurity image with make image-singularity

Run the image with simple.slurm make sure that simple.slurm uses the correct directories
sbatch simple.slurm 
monitor progress
squeue -u $USER

monitor output
in ./output a .err file is created with appropiate slurm job id you can view it with 
less ./output/*.err

in ./output a .out file is created with appropiate slurm job id you can view it with 
less ./output/*.out

to continuosly see the output say
tail -f ./output/*.out

WARNING if you run this multple times you will see multiple .out and .err files and instructions
above will not work , instead identify the last 3 numbers of the job id and use them after
the star 



## 2. Datasets

This test is only for the small dataset.

The datasets can be downloaded from remote server by using AWS CLI:

### AWS Command Line Interface
Ensure you have AWS CLI installed on your system https://aws.amazon.com/cli/.

After installing run the command below to configure the system:

```bash
aws configure 
```
When prompted to enter keys just leave it empty and press enter.

#### Download data
Run the command to download the data from the remote server.

Download will take at least 3 hours.

- real    207m6.905s
- user    0m0.078s
- sys     0m0.124s


```bash
$ aws s3 --no-sign-request --endpoint-url https://s3.echo.stfc.ac.uk sync s3://sciml-datasets/ms/stemdl_ds1a ./
```

The target directory in this case is the local one "./", but any other
directory path with a write permission can also be provided.  As a
result of the aws command four directories will be created: training,
testing, validation and inference.

## 3. Installation 



It is recommended to run the Stemdl benchmark in the Anaconda environment.

0. Activate WSL:
```bash
$ wsl
```

1. If Anaconda is not already installed on the system, it can be
   downloaded from here:
 
   ```bash
   $ wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
   ```

2. Install Anaconda

   ```bash
   $ bash Anaconda3-2021.05-Linux-x86_64.sh`
   ```
   
3. Create conda environment

   ```bash
   $ conda create --name bench python=3.8
   ```

4. Activate environment



   ```bash
   eval "$(/home/$USER/anaconda3/bin/conda shell.bash hook)"
   conda activate bench`
   pip install -r requirements.txt -U 
   cms help
   ```

## 4. Running the benchmark

```bash
$ python stemdl_classification.py --config stemdlConfig.yaml
```

