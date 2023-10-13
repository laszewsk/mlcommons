# Cloudmask on Summit

## Environment

add to your .bashrc

```bash
module purge
module load open-ce


export CLOUDMASK_DATA="/gpfs/alpine/gen150/proj-shared/jpdata/datasets/slstr_cloud"
export WORKDIR="/gpfs/alpine/gen150/proj-shared/$USER"
export SCIML="$WORKDIR/slstr_cloud/sciml-bench"

cd $WORKDIR
pwd
```

Then 

```bash
source ~/.bashrc
```

## Set up python

```bash
python -m venv $WORKDIR/ENV3
source $WORKDIR/ENV3/bin/activate
time pip install pip -U
# 7 seconds
time pip install cloudmesh-ee
# 16 s
cd $SCIML
time pip install -e .
```
