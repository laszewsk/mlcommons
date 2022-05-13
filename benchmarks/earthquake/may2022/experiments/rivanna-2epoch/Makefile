
all: project localscratch generate

submit: all
	sh jobs-project.sh

.PHONY: project

project:
	cms sbatch generate rivanna.in.slurm --setup=rivanna-2epoch.yaml --name="project" --noos


.PHONY: generate
generate:
	cms sbatch generate submit --name=project.json > jobs-project.sh
	cat jobs-project.sh

.PHONY: run
run:
	sh ./jobs-project.sh

.PHONY: stop
stop:
	for i in "$$(squeue --user $$USER | awk 'NR>1{print $$1}')"; do scancel $$i ; done

.PHONY: clean
clean:
	@-rm -rf project project.json jobs-project.sh
	@-rm -f rivanna.slurm
