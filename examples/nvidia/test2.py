import tensorflow as tf
from pprint import pprint

r = tf.config.list_physical_devices("GPU")

pprint (r)

if "physical_device:GPU" not in str(r):
    print ("Test failed")
else:
 print("test passed")

