import yaml
from cloudmesh.common.util import readfile
from cloudmesh.common.FlatDict import flatten
from util import read_config_parameters

s = """
experiment:
   epoch: 1
   learning_rate: 0.01
   gpu: a100
"""


config  = yaml.load(s)
print (config)

config = read_config_parameters(d=config)

print (config)

for key, value in config.items():
    print (key, value, type(value))
