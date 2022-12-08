import yaml
from cloudmesh.common.util import readfile
from cloudmesh.common.FlatDict import flatten


def read_config_parameters(filename=None, d=None):
    if filename is None:
        config = {}
    else:
        config = readfile(filename)
        config = yaml.load(config)
    if d is not None:
        config.update(d)
    config = flatten(config, sep=".")
    return config
