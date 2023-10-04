from cloudmesh.common.FlatDict import FlatDict
from cloudmesh.common.util import banner
import os
from pprint import pprint

configYamlFile = os.path.expanduser("a.yaml")

print("Config file:", configYamlFile)

config = FlatDict()
config.load(content=configYamlFile)

s = str(config)



print(type(config))
pprint(config.__dict__)