---
title: "TEvolOp Earthquake Forecasting"
linkTitle: "Earthquake"
date: 2017-01-05
weight: 4
description: >
  Forcasting Earthquakes
---

{{% pageinfo %}}
Forcatsing Earthquakes
{{% /pageinfo %}}

### TEvolOp Earthquake Forecasting

Time series are seen in many scientific problems and many of them are
geospatial -- functions of space and time and this benchmark illustrates
this type. Some time series have a clear spatial structure that for
example strongly relates nearby space points. The problem chosen is
termed a spatial bag where there is spatial variation but it is not
clearly linked to the geometric distance between spatial regions. In
contrast, traffic-related time series have a strong spatial structure.
We intend benchmarks that cover a broad range of problem types.

The earthquake data comes from USGS and we have chosen a 4 degrees of
Latitude (32 to 36 N) and 6 degrees of Longitude (-120 to -114) region
covering Southern California. The data runs from 1950 to the present day
and is presented as events: magnitude, ground location, depth, and time.
We have divided the data into time and space bins. The time interval is
daily but in our reference models, we accumulate this into fortnightly
data. Southern California is divided into a 40 by 60 grid of 0.1 by
0.1-degree "pixels" which corresponds roughly to squares with an 11 km
side, The dataset also includes an assignment of pixels to known faults
and a list of the largest earthquakes in that region from 1950 until
today. We have chosen various samplings of the dataset to provide both
input and predicted values. These include time ranges from a fortnight
up to 4 years. Further, we calculate summed magnitudes and depths and
counts of significant quakes (magnitude \> 3.29). Other easily available
quantities are powers of quake energy (using Energy \~ 101.5m where m is
magnitude). Quantities are "Energy averaged" when there are multiple
events in a single space-time bin except for simple event counts.

Current reference models are a basic LSTM recurrent neural network and a
modification of the original science transformer. Details can be found
[here](https://docs.google.com/presentation/d/1ykYnX0uvxPE-M-c-Tau8irU3IqYuvj8Ws8iUqd5RCxQ/edit?usp=sharing),
and
[here](https://www.researchgate.net/publication/346012611_DRAFT_Deep_Learning_for_Spatial_Time_Series).

#### TEvolOp Specific Benchmark Targets

1.  Scientific objective(s):
    -   Objective: Improve the quality of Earthquake forecasting
    -   Formula: Normalized Nash--Sutcliffe model efficiency coefficient
        (NNSE)
    -   Score: The NNSE lies between 0.8 and 0.99 depending on model and
        predicted time series
2.  Data
    -   Download:
        <https://drive.google.com/drive/folders/1wz7K2R4gc78fXLNZMHcaSVfQvIpIhNPi?usp=sharing>
    -   Data Size: 5GB from USGS
    -   Training samples: Data is decided spatially in an 80%-20%
        fashion between training and validation. The full dataset covers
        6 degrees of longitude (-114 to -120) and 4 degrees of latitude
        (32 to 56) In Southern California. This is divided into 2400
        spatial bins 0.1 degree (\~11km) on a side
    -   Validation samples: Most analyses use 500 most active bins of
        which 400 are training and 100 validation.
3.  Example implementation
    -   Model: 3 state of the art geospatial deep learning
        implementations are provided
    -   Reference Code:
        <https://colab.research.google.com/drive/1JrPcRwX06xIN5iLhc53_MOLzU9q_Q7wD?usp=sharing>
        (Second model below)
    -   Run Instructions: This is set up currently as a Jupyter notebook
        to run on Colab/GitHub. A container DGX version is also
        available
    -   Time-to-solution: 1 to 2 days on a single GPU

## Example Implementation:

The example implementation is primarily to demonstrate feasibility, show
how the data is represented, help address any interpretation
considerations, and potentially trigger initial ideas on how the
benchmark can be improved.

