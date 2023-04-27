from cloudmesh.common.util import banner
import tensorflow as tf
available = tf.test.is_gpu_available()
count = tf.config.list_physical_devices("GPU").__len__()

banner("GPUs")

print(f"GPU available: {available}")
print(f"GPUs:          {count}")
print()
