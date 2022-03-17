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

run:
	docker run --gpus all -it --rm tensorflow/tensorflow:latest-gpu python mnist.py
