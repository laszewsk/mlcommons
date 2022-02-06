all: compile run

compile:
	nvcc -o test test.cu

run:
	./test
	@echo
	@echo "if it prints 'Max error: 0.000000' it is ok"
