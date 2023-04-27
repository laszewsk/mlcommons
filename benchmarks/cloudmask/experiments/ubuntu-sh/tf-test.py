
from cloudmesh.common.util import banner
import tensorflow as tf
from tensorflow.python.client import device_lib

def get_available_gpus():
    local_device_protos = device_lib.list_local_devices()
    return [x.name for x in local_device_protos if x.device_type == 'GPU']

gpus = get_available_gpus()


available = tf.test.is_gpu_available()
count = tf.config.list_physical_devices("GPU").__len__()

banner("GPUs")

print(f"GPU available: {available}")
print(f"GPUs:          {count}")
print()

print (gpus)
print()


