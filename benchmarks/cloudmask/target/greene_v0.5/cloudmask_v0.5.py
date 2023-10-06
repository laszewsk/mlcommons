#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# slstr_cloud.py

# SciML-Bench
# Copyright © 2022 Scientific Machine Learning Research Group
# Scientific Computing Department, Rutherford Appleton Laboratory
# Science and Technology Facilities Council, UK.
# with modifications from Gregor von Laszewski, Juri Papay
# All rights reserved.

# import sys
# sys.path.append("..")

import yaml
import os

os.environ['PYTHONHASHSEED'] = str(0)

import atexit
import h5py
import time
import decimal
import argparse
import tensorflow as tf
from data_loader import load_datasets
from model import unet
from pathlib import Path
import numpy as np
from data_loader import SLSTRDataLoader
from cloudmesh.common.StopWatch import StopWatch
from sklearn import metrics
from mlperf_logging import mllog
import logging
from tensorflow.keras.callbacks import EarlyStopping, LearningRateScheduler
from cloudmesh.common.FlatDict import FlatDict
from cloudmesh.common.util import banner
import random


# config = read_config_parameters(filename='config.yaml')

# print(config)

# Loss function
def weighted_cross_entropy(beta):
    """
    Weighted Binary Cross Entropy implementation
    :param beta: beta weight to adjust relative importance of +/- label
    :return: weighted BCE loss
    """

    def convert_to_logits(y_pred):
        # see https://github.com/tensorflow/tensorflow/blob/r1.10/tensorflow/python/keras/backend.py#L3525
        y_pred = tf.clip_by_value(
            y_pred, tf.keras.backend.epsilon(), 1 - tf.keras.backend.epsilon())

        return tf.math.log(y_pred / (1 - y_pred))

    def loss(y_true, y_pred):
        y_pred = convert_to_logits(y_pred)
        loss = tf.nn.weighted_cross_entropy_with_logits(
            logits=y_pred, labels=y_true, pos_weight=beta)

        # or reduce_sum and/or axis=-1
        return tf.reduce_mean(loss)

    return loss


def reconstruct_from_patches(config, patches: tf.Tensor, nx: int, ny: int, patch_size: int) -> tf.Tensor:
    """Reconstruct a full image from a series of patches

    :param config: image height and image width defined in IMAGE_H and IMAGE_W
    :param patches: array with shape (num patches, height, width)
    :param nx: the number of patches in the x direction
    :param ny: the number of patches in the y direction
    :param patch_size: the size of th patches
    :return: the reconstructed image with shape (1, height, weight, 1)
    """
    # Read arguments 
    IMAGE_H = config['image.IMAGE_H']
    IMAGE_W = config['image.IMAGE_W']

    h = ny * patch_size
    w = nx * patch_size
    reconstructed = np.zeros((1, h, w, 1))

    for i in range(ny):
        for j in range(nx):
            py = i * patch_size
            px = j * patch_size
            reconstructed[0, py:py + patch_size, px:px + patch_size] = patches[0, i, j]

    # Crop off the additional padding
    offset_y = (h - IMAGE_H) // 2
    offset_x = (w - IMAGE_W) // 2
    reconstructed = tf.image.crop_to_bounding_box(reconstructed, offset_y, offset_x, IMAGE_H, IMAGE_W)
    return reconstructed


# Inference
def cloud_inference(config) -> None:
    banner('Running benchmark slstr_cloud in inference mode.')
    global modelPath
    # Read arguments 
    CROP_SIZE = config['image.CROP_SIZE']
    PATCH_SIZE = config['image.PATCH_SIZE']
    N_CHANNELS = config['image.N_CHANNELS']

    # Load model
    # modelPath = os.path.expanduser(config['output.model_file'])
    model = tf.keras.models.load_model(modelPath)

    # Read inference files
    inference_dir = os.path.expanduser(config['data.inference'])
    file_paths = list(Path(inference_dir).glob('**/S3A*.hdf'))

    # Create data loader in single image mode. This turns off shuffling and
    # only yields batches of images for a single image at a time, so they can be
    # reconstructed.
    data_loader = SLSTRDataLoader(config, file_paths, single_image=True, crop_size=CROP_SIZE)
    # data_loader = SLSTRDataLoader(config, file_paths, single_image=False, crop_size=CROP_SIZE)
    dataset = data_loader.to_dataset()

    # Inference Loop
    accuracyList = []
    for patches, file_name in dataset:
        file_name = Path(file_name.numpy().decode('utf-8'))

        # convert patches to a batch of patches
        n, ny, nx, _ = patches.shape
        patches = tf.reshape(patches, (n * nx * ny, PATCH_SIZE, PATCH_SIZE, N_CHANNELS))

        # perform inference on patches
        mask_patches = model.predict_on_batch(patches)
        # mask_patches = model.test_on_batch(patches) # might return also the accuracy

        # crop edge artifacts
        mask_patches = tf.image.crop_to_bounding_box(
            mask_patches,
            CROP_SIZE // 2,
            CROP_SIZE // 2,
            PATCH_SIZE - CROP_SIZE,
            PATCH_SIZE - CROP_SIZE)
        # reconstruct patches back to full size image
        mask_patches = tf.reshape(mask_patches, (n, ny, nx, PATCH_SIZE - CROP_SIZE, PATCH_SIZE - CROP_SIZE, 1))
        # Mask produced by inference
        mask = reconstruct_from_patches(config, mask_patches, nx, ny, patch_size=PATCH_SIZE - CROP_SIZE)

        # Save reconstructed image (mask)
        output_dir = os.path.expanduser(config['output.directory'])

        mask_name = f"{output_dir}/mask/{file_name.name}.h5"
        mask_dir = f"{output_dir}/mask"

        try:
            os.makedirs(mask_dir)
        except Exception as e:
            pass

        with h5py.File(mask_name, 'w') as handle:
            handle.create_dataset('mask', data=mask)
            handle.create_dataset('mask_patches', data=mask_patches)
            handle.create_dataset('patches', data=patches)

        # Change mask values from float to integer
        mask_np = mask.numpy()
        mask_np = (mask_np > .5).astype(int)
        mask_flat = mask_np.reshape(-1)

        # Extract groundTruth from file, this is the Bayesian mask
        with h5py.File(file_name, 'r') as handle:
            groundTruth = handle['bayes'][:]
            groundTruth[groundTruth > 0] = 1
            groundTruth[groundTruth == 0] = 0

        # Make 1D array
        groundTruth_flat = groundTruth.reshape(-1)

        # Calculate hits between ground truth mask and the reconstructed mask
        accuracy = metrics.accuracy_score(groundTruth_flat, mask_flat)
        accuracyList.append(accuracy)

    d = {
        "avg_accuracy": np.array(accuracyList).mean(),
        "accuracy": accuracyList
    }
    # Return number of files used for inference and disctionary d with accuracy
    return len(file_paths), d


# Learning Rate scheduler
def lr_time_based_decay(epoch, lr):
    decay = 0.001 / 100
    return lr * 1 / (1 + decay * epoch)


def reset_random_seeds(seed):
    os.environ['PYTHONHASHSEED'] = str(seed)
    os.environ['TF_CUDNN_DETERMINISTIC'] = '1'
    random.seed(seed)
    np.random.seed(seed)
    tf.random.set_seed(seed)


#####################################################################
# Training mode                                                     #
#####################################################################

def cloud_training(config) -> None:
    banner('Running benchmark slstr_cloud in training mode.')
    global modelPath
    reset_random_seeds(config['experiment.seed'])
    # tf.random.set_seed(config['experiment.seed'])
    data_dir = os.path.expanduser(config['data.training'])

    # load the datasets
    StopWatch.start("loaddata")
    train_dataset, test_dataset = load_datasets(
        dataset_dir=data_dir,
        config=config)
    StopWatch.stop("loaddata")

    samples = list(Path(data_dir).glob('**/S3A*.hdf'))
    num_samples = len(samples)
    print("num_samples: ", num_samples)

    # Running training on multiple GPUs
    StopWatch.start("training_on_mutiple_GPU")
    mirrored_strategy = tf.distribute.MirroredStrategy()
    optimizer = tf.keras.optimizers.Adam(config['experiment.learning_rate'])

    # Early Stoppage

    def string_to_boolean(input_string):
        if input_string.lower() in ["true", "1"]:
            return True
        elif input_string.lower() in ["false", "0"]:
            return False
        else:
            raise ValueError("Invalid input: " + input_string)

    callbacks = None

    config['experiment.early_stoppage'] = string_to_boolean(config['experiment.early_stoppage'])
    config['experiment.early_stoppage_patience'] = int(config['experiment.early_stoppage_patience'])

    # if config['experiment.early_stoppage']:
    #    patience = int(config['experiment.early_stoppage_patience'])
    #    if callbacks is None:
    #        callbacks = []
    #    callbacks.append(EarlyStopping(monitor='val_loss', patience=patience))

    if config['experiment.early_stoppage']:
        callbacks = [EarlyStopping(monitor='val_loss', patience=config['experiment.early_stoppage_patience'])]
        banner("Early Stopping Activated")
    else:
        banner("No Early Stopping")

    with mirrored_strategy.scope():
        # create U-Net model
        model = unet(input_shape=(config['image.PATCH_SIZE'],
                                  config['image.PATCH_SIZE'],
                                  config['image.N_CHANNELS']))
        model.compile(optimizer=optimizer,
                      loss=config['training_loss'],
                      metrics=[config['training_metrics']])
        history = model.fit(train_dataset,
                            validation_data=test_dataset,
                            epochs=int(config['experiment.epoch']),
                            callbacks=callbacks,
                            verbose=1)

    # Close file descriptors
    # atexit.register(mirrored_strategy._extended._collective_ops._pool.close)

    # # save model
    # if(config['run.mode']=="parallel"):
    #     # GVL: thi sis all uneccessary as it is covered by cloudmesh and the yaml file, via flatDict
    #     # we just need a test program showing how to use it or one needs to look up
    #     # usage in cloudmesh.common.FlatDict
    #
    #     # the program should be default be able to run in parallele without any modifications !!!!!!
    #
    #     # Read experiment arguments and create a model path from them
    #     modelPath = ""
    #     experiment_args = ["card_name",
    #                        "gpu_count",
    #                        "cpu_num",
    #                        "mem",
    #                        "repeat",
    #                        "epoch",
    #                        "seed",
    #                        "learning_rate",
    #                        "batch_size",
    #                        "train_split",
    #                        "clip_offset",
    #                        "no_cache",
    #                        "nodes",
    #                        "gpu"]
    #     for arg_name in experiment_args:
    #         modelPath += arg_name
    #         modelPath += ("_" + str(config['experiment.' + arg_name]) + "_")
    #
    #     modelPath+= "model"
    #
    #     if not os.path.exists(modelPath):
    #         os.makedirs(modelPath)
    #
    #     modelPath += "/cloudModel.h5"
    #
    #     print("\n\n"+modelPath+"\n\n")
    #
    # else: # mode: original
    #     modelPath = os.path.expanduser(config['output.model_file'])

    modelPath = os.path.expanduser(config['output.model_file'])

    tf.keras.models.save_model(model, modelPath)
    banner('END slstr_cloud in training mode.')
    StopWatch.stop("training_on_mutiple_GPU")

    result = {
        "samples": num_samples,
        "accuracy": history.history['accuracy'][-1],
        "loss": history.history['loss'][-1],
        "val_loss": history.history['val_loss'][-1],
        "val_accuracy": history.history['val_accuracy'][-1],
        "history": {
            "accuracy": history.history['accuracy'],
            "loss": history.history['loss'],
            "val_loss": history.history['val_loss'],
            "val_accuracy": history.history['val_accuracy']
        },
        "batch_size": config['experiment.batch_size'],
        "crop_size": config['image.CROP_SIZE'],
        "learning_rate": config['experiment.learning_rate']
    }

    return num_samples, result


# #################################
# Main
# #################################
# Running the benchmark: python slstr_cloud.py --config ./config.yaml

def main():
    StopWatch.start("total")
    # Read command line arguments
    parser = argparse.ArgumentParser(
        description='CloudMask command line arguments',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )

    parser.add_argument('--config',
                        default=os.path.expanduser('./config.yaml'),
                        help='path to config file')
    command_line_args = parser.parse_args()

    banner("CONFIG")

    configYamlFile = os.path.expanduser(command_line_args.config)

    print("Config file:", configYamlFile)

    config = FlatDict()
    config.load(content=configYamlFile)

    print(config)

    # setup
    log_file = os.path.expanduser(config['output.log_file'])
    user_name = config["submission.submitter"]

    # MLCommons logging
    mlperf_logfile = os.path.expanduser(config['output.mlperf_logfile'])
    mllog.config(filename=mlperf_logfile)

    print("user", user_name)
    print("log_file", log_file)
    print("mllog", mlperf_logfile)

    mllogger = mllog.get_mllogger()
    logger = logging.getLogger(__name__)

    # Values extracted from config.yaml
    mllogger.event(key=mllog.constants.SUBMISSION_BENCHMARK, value=config['submission.benchmark'])
    mllogger.event(key=mllog.constants.SUBMISSION_ORG, value=config['submission.org'])
    mllogger.event(key=mllog.constants.SUBMISSION_DIVISION, value=config['submission.division'])

    mllogger.event(key=mllog.constants.SUBMISSION_PLATFORM, value=config['system.platform'])
    mllogger.start(key=mllog.constants.INIT_START)

    mllogger.event(key='number_of_ranks', value=config['experiment.gpu'])
    mllogger.event(key='number_of_nodes', value=config['experiment.nodes'])
    mllogger.end(key=mllog.constants.INIT_STOP)

    banner("TRAINING")
    # Training
    StopWatch.start("training")
    start = time.time()
    mllogger.event(key=mllog.constants.EVAL_START, value="Start: Training")
    samples, training_d = cloud_training(config)
    mllogger.event(key=mllog.constants.EVAL_STOP, value="Stop: Training")
    diff = time.time() - start
    elapsedTime = decimal.Decimal(diff)
    time_per_epoch = elapsedTime / int(config['experiment.epoch'])
    time_per_epoch_str = f"{time_per_epoch:.2f}"
    StopWatch.stop("training")

    with open(log_file, "a") as logfile:
        logfile.write(f"CloudMask training, samples = {samples}, "
                      f"epochs={int(config['experiment.epoch'])}, "
                      f"bs={config['experiment.batch_size']}, "
                      f"nodes={config['experiment.nodes']}, "
                      f"gpus={config['experiment.gpu']}, "
                      f"time_per_epoch={time_per_epoch_str}\n")

    banner("INFERENCE")
    # Inference
    StopWatch.start("inference")

    start = time.time()
    mllogger.event(key=mllog.constants.EVAL_START, value="Start: Inference")
    number_inferences, inference_d = cloud_inference(config)
    mllogger.event(key=mllog.constants.EVAL_STOP, value="Stop: Inference")
    diff = time.time() - start
    elapsedTime = decimal.Decimal(diff)
    time_per_inference = elapsedTime / number_inferences
    time_per_inference_str = f"{time_per_inference:.2f}"
    StopWatch.stop("inference")

    print("number_inferences: ", number_inferences)

    banner("RESULT")
    with open(log_file, "a") as logfile:
        logfile.write(f"CloudMask inference, inferences={number_inferences}, "
                      f"bs={config['experiment.batch_size']}, "
                      f"nodes={config['experiment.nodes']}, "
                      f"gpus={config['experiment.gpu']}, "
                      f"time_per_inference={time_per_inference_str}\n")

    result = {
        "name": "cloudmask",
        "training": training_d,
        "inference": inference_d,

        "inference_analyze": {
            "number": number_inferences,
            "bs": config['experiment.batch_size'],
            "nodes": config['experiment.nodes'],
            "gpus": config['experiment.gpu'],
            "time_per_inference": time_per_inference_str
        },

    }
    mllogger.event(key="result", value=result)
    mllogger.end(key=mllog.constants.RUN_STOP,
                 value="CloudMask benchmark run finished",
                 metadata={'status': 'success'})
    mllogger.event(key=mllog.constants.SUBMISSION_STATUS, value='success')

    StopWatch.stop("total")

    StopWatch.benchmark(user=user_name)
    banner("END")


def debug_function():
    print("Debug function called")


if __name__ == "__main__":
    main()
