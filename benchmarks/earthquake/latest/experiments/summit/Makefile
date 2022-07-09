
all: summit generate

generate: jobs-summit.sh

run: submit

submit: all
	sh jobs-summit.sh

.PHONY: summit
summit: summit.json

jobs-%.sh: %.json
	cms sbatch generate submit --name=$< > $@

%.json: summit-config.yaml
	cms sbatch generate summit.in.lsf --setup=$< --name=$(basename $@) --noos

.PHONY: stop
stop:
	for i in "$$(squeue --user $$USER | awk 'NR>1{print $$1}')"; do scancel $$i ; done

.PHONY: clean
clean:
	@-rm -rf summit summit.json jobs-summit.sh
	@-rm -f summit.lsf
