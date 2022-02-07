# Running the code

To run this code, you have two pathways:

1. Using the native python ecosystem via `pip`, or
2. Using the conda ecosystem.

## Running using pip

To run this code using pip, execute

```bash
python -m venv --prompt mlcommons-science venv
source venv/bin/activate # or .\venv\Scripts\activate.bat on windows
python -m pip install -rrequirements.txt
jupytext --to py:percent FFFFWNPFEARTHQ_newTFTv29.ipynb
python FFFFWNPFEARTHQ_newTFTv29.py
```

If you're interested in doing interactive development, you can install the developer-focused modules by running

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
