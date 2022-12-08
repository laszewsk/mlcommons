import yaml
from cloudmesh.common.util import readfile
from cloudmesh.common.FlatDict import flatten


def read_config_parameters(filename=None, d=None):
    """
    THis file reads in configuration parameters defined in a yaml file and
    produces a flattend dict. It reads in the yaml date from a filename and/or
    a string.  If both are specified the data in the filename will be read first
    and updated with the string.

    s = '''
    experiment:
       epoch: 1
       learning_rate: 0.01
       gpu: a100
    '''

    once read in it returns the flattened dict. To just load from a string use

    config = read_config_parameters(d=s)
    print (config)

    {'experiment.epoch': 1,
     'experiment.learning_rate': 0.01,
     'experiment.gpu': 'a100'}

    :param filename: The filename to read the yaml data from if the filename is not None
    :type filename: string
    :param d: The yaml data includes in a string. That will be added to the dict
    :type d: string
    :return: the flattned dict
    :rtype: dict
    """
    if filename is None:
        config = {}
    else:
        config = readfile(filename)
        config = yaml.safe_load(config)
    if d is not None:
        data = yaml.safe_load(d)
        config.update(data)
    config = flatten(config, sep=".")
    return config
