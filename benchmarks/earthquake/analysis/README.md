# Earthquake Experiment Analysis Notebooks

This README outlines how to generate analysis output for the earthquake experiments.

## Setup

1. Create a directory to store the outputs of the experiments
2. Use the following directory structure to store the outputs
```bash
 results
   |-- computer
   |   |-- filesystem
   |   |   |-- year-month-day
   |   |   |   |-- experiment-name
   |   |   |   |   |-- outputFiles

```
example
```bash
 results
   |-- rivanna
   |   |-- localscratch
   |   |   |-- 2022-07-05
   |   |   |   |-- card_name_v100_gpu_count_1_cpu_num_6_mem_32GB_TFTTransformerepochs_2
   |   |   |   |   |-- config.yaml
   |   |   |   |   |-- _output
   |   |   |   |   |-- slurm.sh
   |   |   |   |   |-- uqq5zz-38718151.err
   |   |   |   |   |-- uqq5zz-38718151.out
```
3. Copy the collect_earthquake_data.ipynb notebook to the results directory and execute the entire notebook
- This will generate a pickle file named 'experiment_data.pkl' which stores relevant data
