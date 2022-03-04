#!/usr/bin/env python
# coding: utf-8

# # Imports

# In[1]:


import subprocess
import os
import datetime
import gc
import io as io
import math
import random
import string
import sys
import time
from csv import reader, writer
from datetime import date, datetime, timedelta
from pprint import pprint
from textwrap import wrap
from textwrap import dedent

import matplotlib
import matplotlib.dates as mdates
import matplotlib.patches as patches
import matplotlib.pyplot as plt
import numpy as np
import oyaml as yaml
import pandas as pd
import tensorflow as tf
# import tensorflow_datasets as tfds
from cloudmesh.common.console import Console
from cloudmesh.common.dotdict import dotdict
from cloudmesh.common.Shell import Shell
from cloudmesh.common.StopWatch import StopWatch
from cloudmesh.common.util import banner, path_expand
from matplotlib.figure import Figure
from matplotlib.path import Path
from tensorflow.keras.layers import GRU, LSTM, Dense
from tensorflow.keras.models import Sequential
from tqdm.notebook import tqdm
import tensorflow
from cloudmesh.common.util import writefile 

from typing import Callable, Dict, List, Optional, Tuple, Union

