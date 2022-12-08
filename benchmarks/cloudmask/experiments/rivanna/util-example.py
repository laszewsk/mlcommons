import yaml
from util import read_config_parameters

s = """
experiment:
   epoch: 1
   learning_rate: 0.01
   gpu: a100
"""


config = read_config_parameters(d=s)

print (config)

for key, value in config.items():
    print (key, value, type(value))
