#!/usr/bin/env python
# from cloudmesh.common.Shell import Shell
# from cloudmesh.common.Shell import Console
import sys
import os
from pprint import pprint
from cloudmesh.common.FlatDict import read_config_parameters

config = read_config_parameters(filename='config.yaml')

pprint(config)
