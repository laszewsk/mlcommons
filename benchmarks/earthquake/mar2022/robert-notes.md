

```bash
cms sbatch generate rivanna.in.slurm 
  --config=sbatch-rivanna-localscratch.yaml
  --name=earthquake2 \
  --experiment=\"card_name=v100 gpu_count=1 cpu_num=6 mem=32GB,64GB\"
  --attribute=\"time=12:00:00\"
  --mode=h
  --dir=localscratch
```

## Implement in SBATCH
cms sbatch generate rivanna.in.slurm --experiment_file=experiment.yaml

```yaml
experiment.yaml:
  config: sbatch-rivanna-localscratch.yaml
  name: earthquake2
  experiment:
    card_name: v100
    gpu_count: 1
    cpu_num: 6
    mem: "32GB,64GB"
  attribute:
    time: 12:00:00
  mode: h
  dir: localscratch
```



## Summit

https://docs.olcf.ornl.gov/systems/summit_user_guide.html#batch-scripts

(uses BSUB vs SBATCH via LSF command)
Consider converting SLURM command to handle summit.in.lsf.sh

```bash
 #!/bin/bash
 # Begin LSF Directives
 #BSUB -P ABC123
 #BSUB -W 3:00
 #BSUB -nnodes 2048
 #BSUB -alloc_flags gpumps
 #BSUB -J RunSim123
 #BSUB -o RunSim123.%J
 #BSUB -e RunSim123.%J

### Review Tensorflow at Summit
### User Guide: https://docs.olcf.ornl.gov/systems/summit_user_guide.html?highlight=tensorflow#automatic-mixed-precision-amp-in-machine-learning-frameworks
# Need to investigate how to start tensorflow on summit using just 1 GPU
 cd $MEMBERWORK/abc123
 cp $PROJWORK/abc123/RunData/Input.123 ./Input.123
 date
 jsrun -n 4092 -r 2 -a 12 -g 3 ./a.out
 cp my_output_file /ccs/proj/abc123/Output.123
#
 ```
 
## Suggestion
 
 
```bash
#!/bin/bash
#BSUB -W 1:59
#BSUB -nnodes 1
# GEN150_bench is a project code from Junqi
#BSUB -P GEN150_bench
#BSUB -o log_GPU_1.o%J
#BSUB -J log_GPU_1_Jobx

# You need this module for python and other libraries
module load open-ce

# These installations are application specific
pip install pytorch-lightning==1.5.10
pip install torchvision
pip install scikit-learn
echo "Running the benchmark"
jsrun -n1 -a1 -g1 -c42 -r1 -b none python benchmark.py
```
