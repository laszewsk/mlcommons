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
Example structure:
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
4. Copy the following notebooks to results directory to perform analysis
- plot_GPU_events.ipynb
- plot_GPU_power.ipynb
- plot_GPU_train_times.ipynb
- NNSE_analysis.ipynb

## Analysis notebooks

### plot_GPU_events.ipynb
- Creates plots of the GPU power usage during execution
- Annotates key times during execution

### plot_GPU_power.ipynb
- Generates GPU Power Usage Graphics

### plot_GPU_train_times.ipynb
- Generates Interactive plot of experiments and execution time
- Create custom plots for experiments of interest

### NNSE_analysis.ipynb
- Generate markdown tables for earthquake predictions across epochs
