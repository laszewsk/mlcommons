# Running the code

To run this code, you have two pathways:

1. Using the native python ecosystem via `pip`, or
2. Using the conda ecosystem.

## GET THE DATA

```bash
export EQ="$(pwd)/mlcommons/benchmarks/earthquake"
git clone git@github.com:laszewsk/mlcommons.git
cd "$EQ"
curl -OL https://github.com/laszewsk/mlcommons-data-earthquake/raw/main/data.tar.xz
tar xvf data.tar.xz
python -m venv --prompt mlcommons-science venv
source venv/bin/activate # or .\venv\Scripts\activate.bat on windows
python -m pip install -r "mar2022/requirements.txt"
```

this will create all data files necessary to run the notebook.

## Running notebook interactively

```bash
jupyter lab mar2022/FFFFWNPFEARTHQ_newTFTv29-gregor.ipynb
```

## Running using pip from the commandline

To preserver the original code, we first create a copy

```bash
cp mar2022/FFFFWNPFEARTHQ_newTFTv29.ipynb mar2022/FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb 
```

To run this code using pip, execute

```bash
jupyter nbconvert --to notebook --execute feb-2022/FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb
```

To see the output, you need to open the notebook.


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