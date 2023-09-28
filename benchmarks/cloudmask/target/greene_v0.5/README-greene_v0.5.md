# All-Encompassing Guide on <mark>greene_v0.5</mark> directory (GRC version)

## Nomenclature
* [PROJ_DIR] := greene_v0.5/ (or greene/)

## Main Changes from greene directory (NYU version)
1. Singularity implementation with Miniconda Overlay
2. Improved reproduce_experiments.sh to GRCtest_reproduce_experiments.sh
3. Added toggle on early_stoppage
4. Added helper bash scripts (clean_outputs.sh, archive_outputs.sh)
5. Improved visualizer.py, changed format to .ipynb


## 1. Singularity with Miniconda Overlay
[Put in the README you created a few weeks ago]


## 2. GRCtest_reproduce_experiments.sh ("New")
It is an automation script that allows you to run multiple experiments, varying on epoch and repeat.

### What has changed from reproduce_experiments.sh ("Old")
* Old creates arrays of pairs of config*.yaml and slurm script, and floods [PROJ_DIR]
* New creates those files and organize them in two subdirectories: <mark>config_reproduce_experiments/</mark> and <mark>slurm_reproduce_experiments/</mark>
* New also provides two variables (??, ??) to change which slurm script to base on when running reproduce.
```bash
???
```

### How to run GRCtest_reproduce_experiments.sh
1. Change variables (??,??) using editor
```bash
???
```
2. cd to [PROJ_DIR] and run the script
```bash
bash GRCtest_reproduce_experiments.sh
```
<mark>WARNING!!! ONLY RUN GRCtest_reproduce_experiments.sh ONE AT A TIME. OTHERWISE, YOU WON'T BE ABLE TO TELL RESULTS FROM ONE REPRODUCE RUN FROM ANOTHER.</mark>

Adviced method
1. First, run clean_outputs.sh to get your [PROJ_DIR] ready for experiment
2. Second, run GRCtest_reproduce_experiments.sh
3. Lastly, run archive_outputs.sh to archive the outputs

```bash
bash clean_outputs.sh
bash GRCtest_reproduce_experiments.sh
bash archive_outputs.sh
```

## 3. Early_stoppage

### Toggle for early_stoppage
The toggle is in config_simple.yaml
```yaml
hyperparameter:
    early_stoppage: True
...
...
...
experiment:
    early_stoppage_tolerance: 25
```
To turn early_stoppage off, set early_stoppage to False, vice versa. Your can also change the tolerance (default is 25) to change the patience.

Once changing is done, you can run experiments (also works for GRCtest_reproduce_experiments.sh).


## 4. Helper Scripts
There are two helper scripts: clean_outputs.sh and archive_outputs.sh

### clean_outputs.sh
This is an automation bash script that helps you clean up all the outputs resulting from running experiments. BE CAREFUL WHEN USING IT!!

#### Understand what clean_outputs.sh deletes
* all output and error files in [PROJ_DIR]/outputs (including gpu0.log), and [PROJ_DIR]/outputs/slstr_cloud
* config_reproduce_experiments/
* slurm_reproduce_experiments/
* __pycache
* trained model (e.g. card_name_*)
* logs (cloudmask logs, mlperf logs)
```bash
??
```
* ???


#### How to run clean_outputs.sh
```bash
bash clean_outputs.sh
```

### archive_outputs.sh
This is an automation bash script that helps you archive all the outputs resulting from running experiments.

#### What does archive_outputs.sh do?
* its goal is to completely archive the relavent experiment results
* it saves all experiment results to [PROJ_DIR]/archive_results/
* move all output and error files in [PROJ_DIR]/outputs (including gpu0.log), and [PROJ_DIR]/outputs/slstr_cloud to [PROJ_DIR]/archive_results/[Date]\_epoch[#]\_[no_]early_stoppage

#### How to run archive_outputs.sh
```bash
bash archive_outputs.sh
```