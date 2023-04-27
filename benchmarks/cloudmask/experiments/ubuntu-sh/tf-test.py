import tensorflow as tf
print(tf.test.is_gpu_available())
tf.config.list_physical_devices("GPU").__len__() > 0
