
18: 
	-rm -rf outputs-18
	mkdir -p outputs-18/h5
	bsub  cloud_GPU_18.job

w18:
	tail -f outputs-18/cloudmask_gpu_18-*.log


all: 2 4 6 12 18 24 w
# 30

2:
	-rm -rf outputs-2
	mkdir -p outputs-2/h5
	bsub  cloud_GPU_2.job

w2:
	tail -f outputs-2/cloudmask_gpu_2-*.log

4: 
	-rm -rf outputs-4
	mkdir -p outputs-4/h5
	bsub  cloud_GPU_4.job

w4:
	tail -f outputs-4/cloudmask_gpu_4-*.log

6: 
	-rm -rf outputs-6
	mkdir -p outputs-6/h5
	bsub  cloud_GPU_6.job

w6:
	tail -f outputs-6/cloudmask_gpu_6-*.log


12: 
	-rm -rf outputs-12
	mkdir -p outputs-12/h5
	bsub  cloud_GPU_12.job

w12:
	tail -f outputs-12/cloudmask_gpu_12-*.log

24: 
	-rm -rf outputs-24
	mkdir -p outputs-24/h5
	bsub  cloud_GPU_24.job

w24:
	tail -f outputs-24/cloudmask_gpu_24-*.log

30: 
	-rm -rf outputs-30
	mkdir -p outputs-30/h5
	bsub  cloud_GPU_30.job

w30:
	tail -f outputs-30/cloudmask_gpu_30-*.log

w:
	watch bjobs
