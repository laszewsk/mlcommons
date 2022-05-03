
all: project localscratch generate

.PHONY: project
project:
	cms sbatch generate rivanna.in.slurm --setup=rivanna-experiments.yaml --name="project" --noos

.PHONY: localscratch
localscratch:
	cms sbatch generate rivanna.in.slurm --setup=rivanna-localscratch-experiments.yaml --name="localscratch" --noos

.PHONY: cli
cli:
	cms sbatch generate rivanna-project.in.slurm --config=sbatch-rivanna.yaml --name=earthquake --noos --experiment=\"card_name=a100 gpu_count=1 cpu_num=6 mem=32GB\" --attribute=\"time=12:00:00\" --mode=h --dir=project

.PHONY: generate
generate:
	cms sbatch generate submit --name=project.json > jobs-project.sh
	cms sbatch generate submit --name=localscratch.json > jobs-localscratch.sh

.PHONY: run
run:
	sh ./jobs-project.sh
	sh ./jobs-localscratch.sh

.PHONY: clean
clean:
	@-rm -r localscratch localscratch.json jobs-localscratch.sh
	@-rm -r project project.json jobs-project.sh
