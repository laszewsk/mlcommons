# MLCommons Science 

* Earthquake TFT Model

## Background


## System Setup

This benchmark has predefined experiments for the following system configurations:

* [NVidia DGX Workstation](./systems/dgxstation/README.md)
* [University of Virginia Rivanna](./systems/rivanna/README.md)

It's advised that you follow thea above instructions if you plan to run this benchmark on these systems.

Note that the NVidia DGX Workstation configuration can work on any Ubuntu workstation that has CUDA, cuDNN, and python 3.8+ installed.


### Custom Execution

To run the MLCommons Science Earthquake TFT notebook, there are a few prerequesits we assume about your system:

1. We assume that you are running on Linux-like workstation with posix tools availible.  (Git-Bash on windows is untested)
2. We assume you have a modern version of python installed, and python 3 is exposed as the `python` command.
3. We assume you have installed the NVIDIA CUDA drivers and cuDNN libraries.
4. We assume you have cloned the following repositories:
   * the MLCommons-Science repository <url-here>.
   * the earthquake dataset <url-here>.

#### Establishing your python environment

First establish establish a virtual enviornment and install all the requirements as defined in the [requirements.txt](./requirements.txt) file.

  
```bash
python -m venv venv.earthquake
source venv.earthquake/bin/activate
python -m pip install -r requirements.txt
```

#### Configure Hyperparameters

Make a copy of the [config.yaml.tmpl](./config.yaml.tmpl) and name it as `config.yaml`.
This file has defaults for the simplist model generation as written.
See the inline comments that explain the purpose of each parameter and for how you can configure them.

Take note of the configurations you set for:

* meta.uuid
* run.workdir
* run.datadir

You will need these values when setting up the data for the model.

#### Setting up the data

Extract the data.tar.xz file located from the earthquake dataset repository so that the files are positioned in the directory of `run.workdir/<username>/workspace-0`.
This can be done automatically by running the below script (assuming the data.tar.xz is in the current directory)

```bash
META_UUID="0"
RUN_WORKDIR="workspace"
MYUSER="$(whoami)"
#---
RUN_BASE="${RUN_WORKDIR}/${MYUSER}/workspace-${META_UUID}"
mkdir -p $RUN_BASE
tar -xf data.tar.xz -C $RUN_BASE
```

#### Running the notebook

If all the above has been run, you should now be able to run the notebook interactively using jupyterlab or as a batch execution using papermill.

```bash
papermill "FFFFWNPFEARTHQ_newTFTv29-gregor-parameters-fig.ipynb" \
          "output.ipynb"
```

This will create a new notebook named `output.ipynb` that contains the resulting Jupyter notebook.

Additional output, such as images, logs, and checkpoints can be obtained in the folder `$RUN_BASE/data/EarthquakeDec2020/Outputs`.

**Caution**: The above papermill command can take multiple hours, even days to execute.
It's advised that you run this command on a system that will not experience any forced logouts or premature terminations of your desktop session.
You may use the `nohup` command to launch the command in the background, but note that all output will be logged to the file `nohup.out`, so feedback will be limited.

**Optional**: If you are interested in reviewing the lower-level GPU logging, immediately before running the papermill process, execute `cms gpu watch --gpu=0 --delay=1 --dense > ${RUN_BASE}/data/EarthquakeDec2020/Outputs/gpu0.log &`.
This will start a background task to monitor your GPU's compute load throughout the execution of the notebook.
Note that you will need to kill this process manually after papermill is completed