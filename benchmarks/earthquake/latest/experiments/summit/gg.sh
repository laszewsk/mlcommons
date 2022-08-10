
# ----------------------------------------------------------------------
# arguments
# ----------------------------------------------------------------------
# 131:do_sbatch /autofs/nccs-svm1_home1/gregorvl/cm/cloudmesh-sbatch/cloudmesh/sbatch/command/sbatch.py
# ----------------------------------------------------------------------
# {'--attributes': None,
#  '--config': None,
#  '--dir': None,
#  '--dryrun': False,
#  '--experiment': None,
#  '--mode': 'debug',
#  '--name': 'summit.json',
#  '--nocm': False,
#  '--noos': False,
#  '--out': None,
#  '--setup': None,
#  '--type': 'lsf',
#  '--verbose': False,
#  'SOURCE': None,
#  'account': None,
#  'attributes': None,
#  'config': None,
#  'dryrun': False,
#  'experiment': None,
#  'filename': None,
#  'generate': True,
#  'gpu': None,
#  'info': False,
#  'mode': 'debug',
#  'name': 'summit.json',
#  'out': None,
#  'slurm': False,
#  'start': False,
#  'stop': False,
#  'submit': True,
#  'verbose': False}
# ----------------------------------------------------------------------

( card_name=v100 gpu_count=1 cpu_num=1 mem=64GB TFTTransformerepochs=2 cd project/card_name_v100_gpu_count_1_cpu_num_1_mem_64GB_TFTTransformerepochs_2 && bsub slurm.sh )
# Timer: 0.1469s Load: 0.4534s sbatch generate submit --name=summit.json --type=lsf
