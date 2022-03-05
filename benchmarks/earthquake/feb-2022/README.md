# Running the code

To run this code, you have two pathways:

1. Using the native python ecosystem via `pip`, or
2. Using the conda ecosystem.

## GET THE DATA

```bash
mkdir earthquake
wget https://github.com/laszewsk/mlcommons-data-earthquake/raw/main/data.tar.xz
tar xvz data.tar.xz
mv data EarthquakeDec2020
```

this will create all data files in the mv data `EarthquakeDec2020` drectory


## Running using pip from the commandline



To preserver the original code, we first create a copy

```
cp FFFFWNPFEARTHQ_newTFTv29.ipynb FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb 
```

To run this code using pip, execute

```bash
python -m venv --prompt mlcommons-science venv
source venv/bin/activate # or .\venv\Scripts\activate.bat on windows
python -m pip install -rrequirements.txt
jupyter nbconvert --to notebook --execute FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb
```

To see the output, you d need to open the notebook

If you are interested in doing interactive development, you can install the 
developer-focused modules by running 

```bash
source venv/bin/activate # or .\venv\Scripts\activate.bat on windows
python -m pip install -rrequirements-dev.txt
jupyter lab .
```

## Running using Conda

To get this running in Conda, run

```bash
conda env create -f environment.yml
conda activatge mlcommons-science
jupytext --to py:percent FFFFWNPFEARTHQ_newTFTv29.ipynb
python FFFFWNPFEARTHQ_newTFTv29.py
```

If you're interested in doing interactive development, you can install the developer-focused modules by running

```bash
conda activate mlcommons-science
python -m pip install -rrequirements-dev.txt
jupyter lab .
```

## Building the container image

To build a container image of the entire benchmarking system (but not run the benchmark), you can run the commands

```bash
# If running docker
$ docker image build --tag mlcommons-science-earthquake:latest
# If running nerdctl
$ nerdctl image build --tag mlcommons-science-earthquake:latest
```


## Running on Rivanna

TODO - Improve this documentation

1. Login to Rivanna
2. Change to your scratch directory: `/scratch/$USER`
3. Run the following git commands to checkout the code and data
   1. `git clone git@github.com:laszewsk/mlcommons-data-earthquake.git`
   2. `git clone git@github.com:laszewsk/mlcommons.git`
4. Create the directory to house the Earthquake data: `mkdir -p mlcommons/benchmarks/earthquake/feb-2022/data/Earthquake2020`
5. Extract the earthquake data to where the notebook will be looking for the earthquake data:
   1. TODO - change to cms data 
   2. `tar Jxvf mlcommons-data-earthquake/data.tar.xz --strip-components=1 -C mlcommons/benchmarks/earthquake/feb-2022/data/Earthquake2020`
6. Activate cuda and cudnn capabilities `module load cuda cudnn`
7. Activate your ENV3 python and install all dependencies
   1. `source /scratch/$USER/ENV3/bin/activate`
   2. `python -m pip install -r requirements.txt`
   3. `python -m pip install jupyter`
8. Navigate to the benchmark directory:
   1. `cd mlcommons/benchmarks/earthquake/feb-2022`
9. Copy the source notebook to your own version and run it
   1. `cp FFFFWNPFEARTHQ_newTFTv29.ipynb FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb`
   2. `jupyter nbconvert --execute FFFFWNPFEARTHQ_newTFTv29-$USER.ipynb --to notebook`
