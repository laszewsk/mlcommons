
all:
	cms sbatch generate rivanna-project.in.slurm --config=sbatch-rivanna.yaml --name=earthquake --experiment=\"card_name=a100,p100,v100,k80,rtx2080,rtx3080 gpu_count=1 cpu_num=6 mem=32GB,64GB\" --attribute=\"time=12:00:00\" --mode=h --dir=.

small:
	cms sbatch generate rivanna-project.in.slurm --config=sbatch-rivanna.yaml --name=earthquake --experiment=\"card_name=a100 gpu_count=1 cpu_num=6 mem=32GB\" --attribute=\"time=12:00:00\" --mode=h --dir=.

run:
	for i in card_name*; do (cd $$i && sbatch slurm.sh); done