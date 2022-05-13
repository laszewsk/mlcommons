
all: project localscratch generate

submit: all
	sh jobs-project.sh

.PHONY: project generate inspect run stop clean status

project:
	cms sbatch generate rivanna.in.slurm --setup=rivanna-2epoch.yaml --name="project" --noos

generate:
	cms sbatch generate submit --name=project.json > jobs-project.sh
	cat jobs-project.sh

inspect:
	emacs project/card_name_a100_gpu_count_1_cpu_num_6_mem_64GB_TFTTransformerepochs_2/slurm.sh

run:
	sh ./jobs-project.sh

stop:
	for i in "$$(squeue --user $$USER | awk 'NR>1{print $$1}')"; do scancel $$i ; done

status:
	squeue | fgrep $USER

clean:
	@-rm -rf project project.json jobs-project.sh
	@-rm -f rivanna.slurm
