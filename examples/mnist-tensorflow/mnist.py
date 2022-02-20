import subprocess

import tensorflow as tf
from cloudmesh.common.Shell import Shell
from cloudmesh.common.util import banner
import os
import platform
import subprocess
import click


def setgpu_growth():
    gpus = tf.config.list_physical_devices('GPU')
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

    physical_devices = tf.config.list_physical_devices('GPU')
    print("Num GPUs:", len(physical_devices))


@click.command()
@click.option('--cpu', required=False, default=-1, help='Run on CPU')
@click.option('--gpu', required=False, default=-1, help="Run on GPU")
@click.option("--dryrun", required=False, is_flag=True, default=False, help="Do not execute MNIST")
@click.option("--info", required=False, is_flag=True, default=False, help="Do not execute MNIST")
def run(cpu, gpu, dryrun, info):
    mnist = tf.keras.datasets.mnist
    if info:
        system_info()

    setgpu_growth()

    physical_devices = tf.config.list_physical_devices('GPU')
    print("Num GPUs:", len(physical_devices))

    if cpu >= 0:
        device = f"/device:CPU:{cpu}"
        # Force disable CUDA devices
        os.environ["CUDA_VISIBLE_DEVICES"] = "-1"
    elif gpu >= 0:
        device = f'/GPU:{gpu}'
        # gpu_devices = tf.config.experimental.list_physical_devices('GPU')
        # for device in gpu_devices:
        #    tf.config.experimental.set_memory_growth(device, True)

    if not dryrun:
        banner("start mnist")
        with tf.device(device):
            tf.debugging.set_log_device_placement(True)
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

            if info:
                verbose = 1
            else:
                verbose = 0
                
            model.fit(x_train, y_train, epochs=5, verbose=verbose)
            model.evaluate(x_test, y_test, verbose=verbose)


def system_info():
    try:
        cpu_proc = subprocess.Popen(["lscpu"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        cpu_info, stderr = cpu_proc.communicate().decode('utf-8')
        print(cpu_info)
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        cpu_info = platform.uname()
        cpu_proc = subprocess.Popen(['wmic', 'cpu', 'list', 'full'],
                                    stdout=subprocess.PIPE,
                                    stderr=subprocess.PIPE)
        stdout, stderr = cpu_proc.communicate()
        out = stdout.decode('utf-8').strip().split('\r\r\n')
        attrib = dict([tuple(x.strip().split('=')) for x in out])
        print(f"System: {cpu_info.system}")
        print(f"Node Name: {cpu_info.node}")
        print(f"Release: {cpu_info.release}")
        print(f"Version: {cpu_info.version}")
        print(f"Machine: {cpu_info.machine}")
        print(f"Processor: {cpu_info.processor}")
        print(f"Clockspeed (current): {attrib['CurrentClockSpeed']}")
        print(f"Clockspeed (max): {attrib['MaxClockSpeed']}")
        print(f"Architecture: {attrib['DataWidth']}")
        print(f"L2CacheSize: {attrib['L2CacheSize']}")
        print(f"CPU Name: {attrib['Name']}")

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

if __name__ == '__main__':
    run()
