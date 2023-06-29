
from cloudmesh.common.FlatDict import FlatDict
import yaml

f = FlatDict(sep=".")

#filename = "config-new.yaml"
# f.loadf(filename=filename)
# print ("Load from file", f)


filename = "test-data.yaml"

d = {
    "person":
        {"name": "Gregor"},
    "author": "{person.name}"
}

with open(filename, 'w') as file:
    documents = yaml.dump(d, file)

f.loads(content=str(d))
print("Load from string", f)

f.loadd(content=d)
print("Load from dict", f)

f.load(content=filename)
print ("Type Load from file", f)

f.load(content=str(d))
print ("Type Load from string", f)

f.load(content=d)
print ("Type Load from dict", f)


"""

config = read_config_parameters(filename=filename)

pprint (config)

banner("CONFIGURATION")
print (type(config))
print (config)

config = expand_config_parameters(config)

pprint (type(config))

print (os.__file__)
"""
