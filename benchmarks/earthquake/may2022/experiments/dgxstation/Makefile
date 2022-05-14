
all: project generate

submit: all
	sh jobs-project.sh

.PHONY: project generate inspect run stop clean status watch out err status

project:
	cms sbatch generate dgx.in.slurm --setup=dgx-config.yaml --name="project"

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
	sh ./jobs-project.sh

stop:
	for i in "$$(squeue --user $$USER | awk 'NR>1{print $$1}')"; do scancel $$i ; done

watch:
	tail -f project/*/$(shell whoami)-*.err project/*/$(shell whoami)-*.out

out: 
	tail -f project/*/$(shell whoami)-*.out

err: 
	tail -f project/*/$(shell whoami)-*.err

status:
	squeue | fgrep ${USER}

clean:
	@-rm -rf project project.json jobs-project.sh
	@-rm -f dgx.slurm
