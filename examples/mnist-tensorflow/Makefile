rivanna-sync:
	rsync -va * rivanna:
	ssh rivanna pwd
	ssh rivanna ls

rivanna-activate:
	module purge
	module load singularity
	module load anaconda
	# conda create -y -n py3.10 python=3.10
	source activate py3.10
	python -V
	which python


image:
	docker pull tensorflow/tensorflow

run-docker:
	# this is not the right way
	docker run -v `pwd`:`pwd` -w `pwd` -i -t  tensorflow/tensorflow:latest-gpu pip install -r requirements.txt; python mnist.py --gpu=4

run-native:
	pip install -r requirements.txt
	python mnist.py --gpu=4


shell:
	docker run -v `pwd`:`pwd` -w `pwd` --gpus all -it --rm tensorflow/tensorflow:latest-gpu bash

plain:
	pip install -r requirements.txt
	python mnist.py --gpu=4	
	nvidia-smi

clean:
	rm -rf __pycache__
