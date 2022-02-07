from cloudmesh.common.Shell import Shell

import tensorflow
import os

class GPU:

  @staticmethod
  def info():
    # todo: return a string
    lscpu = Shell('lscpu')
    print (lscpu)
    gpu_info = Shell('nvidia-smi')
    gpu_info = '\n'.join(gpu_info)
    if gpu_info.find('failed') >= 0:
      print('Select the Runtime > "Change runtime type" menu to enable a GPU accelerator, ')
    else:
      print(gpu_info)

  @staticmethod
  def device():
    # todo: return a string
    physical_devices = tensorflow.config.list_physical_devices('GPU')
    print("Num GPUs:", len(physical_devices))




