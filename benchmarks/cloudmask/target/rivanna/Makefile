data:
	source activate MLBENCH
	cd /scratch/$USER/mlcommons/benchmarks/cloudmask/
	mkdir -p data/ssts
	mkdir -p data/one-day
	pip install awscli
	aws s3 --no-sign-request --endpoint-url https://s3.echo.stfc.ac.uk sync s3://sciml-datasets/es/cloud_slstr_ds1/one-day ./data/one-day
	aws s3 --no-sign-request --endpoint-url https://s3.echo.stfc.ac.uk sync s3://sciml-datasets/es/cloud_slstr_ds1/ssts ./data/ssts

run:
	module load anaconda
	conda activate MLBENCH
	python cloudmask_runner.py
