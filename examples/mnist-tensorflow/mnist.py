import tensorflow as tf

import click

import click

@click.command()
@click.option('--cpu', default=-1, help='Run on CPU')
@click.option('--gpu', default=-1, help="Run on GPU")
@click.option("--dryrun", default=0, help="Do not execute MNIST")
@click.option("--info", default=False, help="Do not execute MNIST")
def run(cpu, gpu, dryrun, info):
    mnist = tf.keras.datasets.mnist
    if info:
        print(gpu)
        print(cpu)
        print(dryrun)

        print("Num GPUs Available: ", len(tf.config.list_physical_devices('GPU')))
        return

    if cpu >= 0:
        device=f"/CPU:{cpu}"
    elif gpu >= 0:
        device=f'/device:GPU:{gpu}'

    if dryrun == 1:
        with tf.device(device):
            (x_train, y_train), (x_test, y_test) = mnist.load_data()
            x_train, x_test = x_train / 255.0, x_test / 255.0

            model = tf.keras.models.Sequential([
                tf.keras.layers.Flatten(),
                tf.keras.layers.Dense(512, activation=tf.nn.relu),
                tf.keras.layers.Dropout(0.2),
                tf.keras.layers.Dense(10, activation=tf.nn.softmax)
            ])

            model.compile(optimizer='adam',
                          loss='sparse_categorical_crossentropy',
                          metrics=['accuracy'])

            model.fit(x_train, y_train, epochs=5)
            model.evaluate(x_test, y_test)



if __name__ == '__main__':
    run()




