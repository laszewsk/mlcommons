
all: project generate

submit: all
	sh jobs-project.sh

.PHONY: project generate inspect run stop clean status watch out err status

project:
	cms sbatch generate \
	           --source=dgx.in.slurm \
	           --config=dgx-config.yaml \
	           --name=project \
	           --noos

generate:
	cms sbatch generate submit --name=project.json > jobs-project.sh
	cat jobs-project.sh

inspect:
    # works only if we do one experiement
	emacs project/*/slurm.sh

test:
	cms sbatch generate  dgx-config-test.yaml --out=dgx-config-test-out.yaml --name=a
	cat dgx-config-test-out.yaml

run:
	# sh ./jobs-project.sh
	cd project/card_name_a100_gpu_count_1_cpu_num_1_mem_64GB_TFTTransformerepochs_2; /usr/bin/bash slurm.sh 2>&1 | tee -a $$USER.out

stop:
	for i in "$$(squeue --user $$USER | awk 'NR>1{print $$1}')"; do scancel $$i ; done

watch:
	tail -f project/*/$$USER.out

out: 
	tail -f project/*/$$USER.out

err:
	tail -f project/*/$$USER.out

status:
	squeue | fgrep ${USER}

clean:
	@-rm -rf project project.json jobs-project.sh
	@-rm -f dgx.slurm
