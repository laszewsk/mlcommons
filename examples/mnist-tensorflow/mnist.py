import click
import os
import tensorflow
import tensorflow as tf
from pprint import pprint

from cloudmesh.common.Shell import Shell
from cloudmesh.common.util import banner
from cloudmesh.common.StopWatch import StopWatch
# from cloudmesh.common.StopWatch import StopWatchTimer


def code_info():
    StopWatch.start("git")
    git = {
        "git": {
            "version": Shell.run('git rev-parse --short HEAD').strip(),
            "branch": Shell.run("git rev-parse --abbrev-ref HEAD").strip(),
            "modified": Shell.run("git log -1 --pretty=\"format:%ci\"").strip()
        }
    }
    StopWatch.stop("git")
    return git


def setgpu_growth():
    gpus = tf.config.list_physical_devices('GPU')
    print (gpus)
    if gpus:
        try:
            # Currently, memory growth needs to be the same across GPUs
            for gpu in gpus:
                tf.config.experimental.set_memory_growth(gpu, True)
            logical_gpus = tf.config.list_logical_devices('GPU')
            print(len(gpus), "Physical GPUs,", len(logical_gpus), "Logical GPUs")
        except RuntimeError as e:
            # Memory growth must be set before GPUs have been initialized
            print(e)

    physical_devices = tensorflow.config.list_physical_devices('GPU')
    print("Num GPUs:", len(physical_devices))


@click.command()
@click.option('--cpu', required=False, default=-1, help='Run on CPU')
@click.option('--gpu', required=False, default=-1, help="Run on GPU")
@click.option("--dryrun", required=False, is_flag=True, help="Do not execute MNIST")
@click.option("--info", required=False, is_flag=True, default=False, help="Do not execute MNIST")
@click.option("--log", required=False, default="mnist.log", help="The logfile with temeperature, enery, and dates")
@click.option('--delay', required=False, default=1.0, help='Run on CPU')
@click.option('--user', required=False, default=None, help='username')
@click.option('--node', required=False, default=None, help='nodename')

def run(cpu, gpu, dryrun, info, log, delay, user, node):
    mnist = tf.keras.datasets.mnist
    if info:
        pprint(code_info())

        try:
            os.system("lscpu | fgrep -v Vulnerability |fgrep -v Flags:")
        except:
            pass
        gpu_info = Shell.run("nvidia-smi")

        if gpu_info.find('failed') >= 0:
            print('Select the Runtime > "Change runtime type" menu to enable a GPU accelerator, ')
        else:
            r = Shell.find_lines_with(gpu_info.splitlines(), "NVIDIA-SMI")
            l = r[0].split()
            nvidia_version = l[2]
            driver_version = l[5]
            cuda_version = l[8]
            print(f"Nvida:  {nvidia_version}")
            print(f"Driver: {driver_version}")
            print(f"Cuda:   {cuda_version}")

        setgpu_growth()
        return

    setgpu_growth()

    physical_devices = tensorflow.config.list_physical_devices('GPU')
    print("Num GPUs:", len(physical_devices))

    if cpu >= 0:
        device = f"/CPU:{cpu}"
    elif gpu >= 0:
        device = f'/device:GPU:{gpu}'
        # gpu_devices = tf.config.experimental.list_physical_devices('GPU')
        # for device in gpu_devices:
        #    tf.config.experimental.set_memory_growth(device, True)

    if not dryrun:
        if log:
            os.system(f"cms gpu watch --delay={delay} > {log}.log &")
        StopWatch.start("total")
        banner("start mnist")
        with tf.device(device):
            # with StopWatchTimer("load"):
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

            if info:
                verbose = 1
            else:
                verbose = 0

            StopWatch.start("fit")
            model.fit(x_train, y_train, epochs=5, verbose=verbose)
            StopWatch.stop("fit")

            StopWatch.start("evaluate")
            model.evaluate(x_test, y_test, verbose=verbose)
            StopWatch.stop("evaluate")

        StopWatch.stop("total")
        if user and node:
            StopWatch.benchmark(user=user, node=node)
        else:
            StopWatch.benchmark()

        if log:
            os.system(f"cms gpu kill")


if __name__ == '__main__':
    run()
