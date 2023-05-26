#! /bin/sh

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=3-00:00:00
#SBATCH --partition=bii-gpu
#SBATCH --account=bii_dsc_community
#SBATCH --reservation=bi_fox_dgx
#SBATCH --mem=64GB
#SBATCH --gres=gpu:a100:1
#SBATCH --job-name=earthquake-a100
#SBATCH --output=%u-%j-a100.out
#SBATCH --error=%u-%j-a100.err

HOSTNAME=`hostname`
echo "HOSTNAME:              $HOSTNAME"
echo "SLURM_CPUS_ON_NODE:    $SLURM_CPUS_ON_NODE"
echo "SLURM_CPUS_PER_GPU:    $SLURM_CPUS_PER_GPU"
echo "SLURM_GPU_BIND:        $SLURM_GPU_BIND"
echo "SLURM_JOB_ACCOUNT:     $SLURM_JOB_ACCOUNT"
echo "SLURM_JOB_GPUS:        $SLURM_JOB_GPUS"
echo "SLURM_JOB_ID:          $SLURM_JOB_ID"
echo "SLURM_JOB_PARTITION:   $SLURM_JOB_PARTITION"
echo "SLURM_JOB_RESERVATION: $SLURM_JOB_RESERVATION"
echo "SLURM_SUBMIT_HOST:     $SLURM_SUBMIT_HOST"

CODE_DIR=/scratch/$USER/mlcommons/benchmarks/earthquake/apr2023/rivanna

BASENAME=FFFFWNPFEARTHQ_newTFTv29-mllog
NOTEBOOK_IN=${BASENAME}.ipynb
NOTEBOOK_OUT=${BASENAME}.ipynb

nvidia-smi

echo "Working in $(pwd)"
# echo "Repository Revision: $(git rev-parse HEAD)"
# echo "Python Version: $(singularity run python -V)"
# echo "Running on host: $(hostname -a)"

singularity exec --nv ${CODE_DIR}/earthquake.sif cms gpu watch --gpu=0 --delay=1 --dense > gpu0.log &

# Execute the notebook using papermill

allocations

singularity exec --nv ${CODE_DIR}/earthquake.sif bash -c \
          "papermill ${CODE_DIR}/${NOTEBOOK_IN} \
          ${NOTEBOOK_OUT} \
          --no-progress-bar --log-output --execution-timeout=-1 --log-level INFO"

allocations

echo "==================================================="
seff $SLURM_JOB_ID
