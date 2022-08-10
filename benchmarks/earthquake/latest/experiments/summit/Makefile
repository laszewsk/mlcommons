
all: summit generate


g: s r
	watch bjobs

s: clean
	-rm -rf project
	make -f Makefile all
	sed -i -e "s/sbatch/bsub/g" jobs-summit.sh 

r:
	sh jobs-summit.sh

t:
	tail -f project/card_name_v100_gpu_count_1_cpu_num_1_mem_64GB_TFTTransformerepochs_2/out.* project/card_name_v100_gpu_count_1_cpu_num_1_mem_64GB_TFTTransformerepochs_2/err.*   

w:
	echo "= ERROR ============================"
	cat project/card_name_v100_gpu_count_1_cpu_num_1_mem_64GB_TFTTransformerepochs_2/err.*   
	echo
	echo "= LOG ============================"
	cat project/card_name_v100_gpu_count_1_cpu_num_1_mem_64GB_TFTTransformerepochs_2/out.*   
	echo

generate: jobs-summit.sh

run: submit

submit: all
	sh jobs-summit.sh

.PHONY: summit
summit: summit.json

jobs-%.sh: %.json
	cms sbatch generate submit --name=$< --type=lsf > $@

%.json: summit-config.yaml
	cms sbatch generate summit.in.lsf --config=$< --name=$(basename $@) --noos

.PHONY: stop
stop:
	for i in "$$(squeue --user $$USER | awk 'NR>1{print $$1}')"; do scancel $$i ; done

.PHONY: clean
clean:
	@-rm -rf summit summit.json jobs-summit.sh
	@-rm -f summit.lsf
