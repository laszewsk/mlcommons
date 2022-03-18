import tensorflow as tf
from pprint import pprint
from cloudmesh.common.StopWatch import StopWatch
from cloudmesh.common.util import banner

print("Num GPUs Available: ", len(tf.config.list_physical_devices('GPU')))
gpus = tf.config.list_logical_devices('GPU')

pprint(gpus)

mnist = tf.keras.datasets.mnist

device = f'/device:GPU:0'
verbose = 0

with tf.device('/GPU:0'):
    StopWatch.start("total")
    banner("start mnist")
    with tf.device(device):
        StopWatch.start("load")
        (x_train, y_train), (x_test, y_test) = mnist.load_data()
        x_train, x_test = x_train / 255.0, x_test / 255.0
        StopWatch.stop("load")

        StopWatch.start("model")
        model = tf.keras.models.Sequential([
            tf.keras.layers.Flatten(),
            tf.keras.layers.Dense(512, activation=tf.nn.relu),
            tf.keras.layers.Dropout(0.2),
            tf.keras.layers.Dense(10, activation=tf.nn.softmax)
        ])
        StopWatch.stop("model")

        StopWatch.start("compile")
        model.compile(optimizer='adam',
                      loss='sparse_categorical_crossentropy',
                      metrics=['accuracy'])
        StopWatch.stop("compile")

        StopWatch.start("fit")
        model.fit(x_train, y_train, epochs=5, verbose=verbose)
        StopWatch.stop("fit")

        StopWatch.start("evaluate")
        model.evaluate(x_test, y_test, verbose=verbose)
        StopWatch.stop("evaluate")

    StopWatch.stop("total")
    StopWatch.benchmark()

