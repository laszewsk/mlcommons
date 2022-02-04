---
title: "CloudMask (Segmentation)"
linkTitle: "CloudMask"
date: 2017-01-05
weight: 4
description: >
  Estimation of sea surface temperature (SST) from space-borne sensors.
---

{{% pageinfo %}}
Estimation of sea surface temperature (SST) from space-borne sensors.
{{% /pageinfo %}}


### CloudMask (Segmentation)

Estimation of sea surface temperature (SST) from space-borne sensors,
such as satellites, is crucial for a number of applications in
environmental sciences. One of the aspects that underpins the derivation
of SST is cloud screening, which is a step that marks each and every
pixel of thousands of satellite imageries as containing cloud or clear
sky, historically performed using either thresholding or Bayesian
methods.

This benchmark focuses on using a machine learning-based model for
masking clouds, in the Sentinel-3 satellite, which carries the Sea and
Land Surface Temperature Radiometer (SLSTR) instrument. More
specifically, the benchmark operates on multispectral image data. The
example implementation is a variation of the U-Net deep neural network.
The benchmark includes two datasets of DS1-Cloud and DS2-Cloud, with
sizes of 180GB and 4.9TB, respectively. Each dataset is made up of two
parts: reflectance and brightness temperature. The reflectance is
captured across six channels with the resolution of 2400 x 3000 pixels,
and the brightness temperature is captured across three channels with
the resolution of 1200 x 1500 pixels.

#### CloudMask Specific Benchmark Targets

1.  Scientific objective(s):
    -   Objective: Compare the accuracy produced by the Neural Network
        with the accuracy of a Bayesian method
    -   Formula: Weighted Binary Cross Entropy of validation dat
    -   Score: 0.9 for convergence
2.  Data
    -   Download: aws s3 \--no-sign-request \--endpoint-url
        https://s3.echo.stfc.ac.uk sync s3://sciml-datasets/en/
        cloud_slstr_ds1 .
    -   Data Size: 180GB
    -   Training samples: 15488
    -   Validation samples: 3840
3.  Example implementation
    -   Model: U-Net
    -   Reference Code:
        <https://github.com/stfc-sciml/sciml-bench/tree/master/sciml_bench/benchmarks/slstr_cloud>
    -   Run Instructions:
        <https://github.com/stfc-sciml/sciml-bench/blob/master/README.md>
    -   Time-to-solution: 180GB dataset runs 59 min on DGX-2 with 32
        V100 GPU

