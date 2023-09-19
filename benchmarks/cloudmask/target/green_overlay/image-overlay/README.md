# Setting up cloudmask with Singularity overlay

Gregor von Laszewski (laszewski@gmail.com)
Ruochen Guo


## Step 1: Environment

```bash
greene> 
	export $PROJECT_SOURCE=/scratch/$USER/github/mlcommons/benchmarks/cloudmask/target/greene-overlay
	export $PROJECT_DIR=/scratch/$USER/github/mlcommons/benchmarks/cloudmask/target/greene-overlay-test
	export SCRTACH=/scratch/$USER/github/
```

If you like to automatize the, please set it in your .bashrc file



## Step 2. Setting up Singularity

```bash
greene>
  export $PROJECT_DIR=/scratch/$USER/github/mlcommons/benchmarks/cloudmask/target/rivanna_overlay
  mkdir -p /scratch/$USER/github/
  cd /scratch/$USER/github/
  git clone https://github.com/laszewsk/mlcommons.git
  cd $PROJECT_DIR  
  singularity pull docker://nvcr.io/nvidia/tensorflow:22.10-tf2-py3
  cp tensorflow_22.10-tf2-py3.sif cloudmask.sif
```

## Step 3. Create overlay image

TODO: use native calls rather then bredefined space

```bash
greene>
  cp -rp /scratch/work/public/overlay-fs-ext3/overlay-15GB-500K.ext3.gz .
  gunzip overlay-15GB-500K.ext3.gz
  singularity exec --overlay overlay-15GB-500K.ext3:rw cloudmask.sif /bin/bash
  unset -f which
  which python
  which pip
  python --version
```

## Step 5. Download data if not there

* check if data is there
* download the data using globus

## Step 4. Run a test run to see if it works

todo