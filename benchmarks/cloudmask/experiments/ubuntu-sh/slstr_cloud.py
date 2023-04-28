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
from pprint import pprint

from cloudmesh.common.FlatDict import read_config_parameters

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
    IMAGE_H = config['IMAGE_H']
    IMAGE_W = config['IMAGE_W']

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
    print('Running benchmark slstr_cloud in inference mode.')
    # Read arguments 
    CROP_SIZE = config['CROP_SIZE']
    PATCH_SIZE = config['PATCH_SIZE']
    N_CHANNELS = config['N_CHANNELS']

    # Load model
    modelPath = os.path.expanduser(config['model_file'])
    model = tf.keras.models.load_model(modelPath)

    # Read inference files
    inference_dir = os.path.expanduser(config['inference_dir'])
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
        #mask_patches = model.test_on_batch(patches) # might return also the accuracy

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
        output_dir = os.path.expanduser(config['output_dir'])
        mask_name = output_dir + file_name.name + '.h5'
        with h5py.File(mask_name, 'w') as handle:
            handle.create_dataset('mask', data=mask)
            handle.create_dataset('mask_patches', data=mask_patches)
            handle.create_dataset('patches', data=patches)

        # Change mask values from float to integer
        mask_np = mask.numpy()
        mask_np =  (mask_np > .5).astype(int)
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



#####################################################################
# Training mode                                                     #
#####################################################################

def cloud_training(config) -> None:
    print('Running benchmark slstr_cloud in training mode.')
    tf.random.set_seed(config['experiment.seed'])
    data_dir = os.path.expanduser(config['train_dir'])

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

    with mirrored_strategy.scope():
        # create U-Net model
        model = unet(input_shape=(config['PATCH_SIZE'],
                                  config['PATCH_SIZE'],
                                  config['N_CHANNELS']))
        model.compile(optimizer=optimizer,
                      loss=config['training_loss'],
                      metrics=[config['training_metrics']])
        history = model.fit(train_dataset,
                            validation_data=test_dataset,
                            epochs=int(config['experiment.epoch']),
                            verbose=1)

    # Close file descriptors
    if config["run.close_files"]:
        atexit.register(mirrored_strategy._extended._collective_ops._pool.close)

    # save model
    modelPath = os.path.expanduser(config['model_file'])
    tf.keras.models.save_model(model, modelPath)
    print('END slstr_cloud in training mode.')
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
        }
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

    print ("AAA")

    parser.add_argument('--config',
                        default=os.path.expanduser('./config.yaml'),
                        help='path to config file')
    command_line_args = parser.parse_args()

    configYamlFile = os.path.expanduser(command_line_args.config)
    config = read_config_parameters(filename=configYamlFile)

    log_file = os.path.expanduser(config['log_file'])

    user_name = config["submission.submitter"]

    os.system("mkdir ./outputs")

    pprint(config)

    if config["run.gpu.log_on"]:
        gpu_interval = config["run.gpu.log_interval"]
        gpu_logfile = config["run.gpu.log_file"]
        os.system("cms help")
        os.system(f"cms gpu watch --gpu=0 --delay={gpu_interval} --dense > "
                  f"{gpu_logfile} &")

    if config["run.gpu.debug"]:
        tf.debugging.set_log_device_placement(True)


    print ("AAA")


    # MLCommons logging
    mlperf_logfile = os.path.expanduser(config['mlperf_logfile'])
    mllog.config(filename=mlperf_logfile)
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

    print ("AAA")


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

if __name__ == "__main__":
    main()
