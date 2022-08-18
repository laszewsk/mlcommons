
# ----------------------------------------------------------------------
# arguments
# ----------------------------------------------------------------------
# 130:do_sbatch /home/green/Desktop/cm/cloudmesh-sbatch/cloudmesh/sbatch/command/sbatch.py
# ----------------------------------------------------------------------
# {'--attributes': None,
#  '--config': None,
#  '--dir': None,
#  '--dryrun': False,
#  '--experiment': None,
#  '--mode': 'debug',
#  '--name': 'project.json',
#  '--nocm': False,
#  '--noos': False,
#  '--out': None,
#  '--config': None,
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
#  'name': 'project.json',
#  'out': None,
#  'slurm': False,
#  'start': False,
#  'stop': False,
#  'submit': True,
#  'verbose': False}
# ----------------------------------------------------------------------

card_name=rtx3090 gpu_count=1 cpu_num=1 mem=64GB TFTTransformerepochs=2 sbatch -D project/card_name_rtx3090_gpu_count_1_cpu_num_1_mem_64GB_TFTTransformerepochs_2 slurm.sh
# Timer: 0.0218s Load: 0.1228s sbatch generate submit --name=project.json
