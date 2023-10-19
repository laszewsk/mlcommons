
clean-18:
	rm -rf outputs-18

18: clean-18
	mkdir -p outputs-18/h5
	bsub  cloud_GPU_18.job

clean-2:
	rm -rf outputs-2

2: clean-2
	mkdir -p outputs-2/h5
	bsub  cloud_GPU_2.job

w:
	watch bjobs
