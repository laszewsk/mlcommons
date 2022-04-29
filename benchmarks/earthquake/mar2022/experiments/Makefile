
all: project localscratch

.PHONY: project
project:
	cms sbatch generate rivanna.in.slurm --setup=rivanna-experiments.yaml --name="project" --noos --attribute=\"time=12:00:00\" --mode=h

.PHONY: localscratch
localscratch:
	cms sbatch generate rivanna.in.slurm --setup=rivanna-localscratch-experiments.yaml --name="localscratch" --noos --attribute=\"time=12:00:00\" --mode=h

cli:
	cms sbatch generate rivanna-project.in.slurm --config=sbatch-rivanna.yaml --name=earthquake --noos --experiment=\"card_name=a100 gpu_count=1 cpu_num=6 mem=32GB\" --attribute=\"time=12:00:00\" --mode=h --dir=project

run:
	for i in "$(ls project/card_name* localscratch/card_name*)"; do (cd $$i && sbatch slurm.sh); done

.PHONY: clean
clean:
	@rm -r localscratch localscratch.json
	@rm -r project project.json
