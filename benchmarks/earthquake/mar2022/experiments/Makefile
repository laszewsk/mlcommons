
all: 
	cms sbatch generate rivanna.in.slurm --config=sbatch-rivanna.yaml --name=earthquake --experiment=\"card_name=a100,p100,v100,k80,rtx2080,rtx3080 gpu_count=1 cpu_num=6 mem=32GB,64GB\" --attribute=\"time=12:00:00\" --mode=h --dir=project
	cms sbatch generate rivanna.in.slurm --config=sbatch-rivanna-localscratch.yaml --name=earthquake2 --experiment=\"card_name=v100 gpu_count=1 cpu_num=6 mem=32GB,64GB\" --attribute=\"time=12:00:00\" --mode=h --dir=localscratch

small:
	cms sbatch generate rivanna-project.in.slurm --config=sbatch-rivanna.yaml --name=earthquake --experiment=\"card_name=a100 gpu_count=1 cpu_num=6 mem=32GB\" --attribute=\"time=12:00:00\" --mode=h --dir=project

run:
	for i in "$(ls project/card_name* localscratch/card_name*); do (cd $$i && sbatch slurm.sh); done

clean:
	rm earthquake.json
	rm earthquake2.json
	rm -r localscratch/card_name* localscratch/rivanna.slurm
	rm -r project/card_name* project/rivanna.slurm
