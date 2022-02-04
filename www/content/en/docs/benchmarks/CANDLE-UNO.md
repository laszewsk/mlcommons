---
title: "CANDLE-UNO"
linkTitle: "CANDLE-UNO"
date: 2017-01-05
weight: 4
description: >
  CANDLE (Exascale Deep Learning and Simulation Enabled Precision Medicine
  for Cancer) project aims to implement deep learning architectures that
  are relevant to problems in cancer.
---

{{% pageinfo %}}
CANDLE (Exascale Deep Learning and Simulation Enabled Precision Medicine
for Cancer) project aims to implement deep learning architectures that
are relevant to problems in cancer.
{{% /pageinfo %}}



### CANDLE-UNO

CANDLE (Exascale Deep Learning and Simulation Enabled Precision Medicine
for Cancer) project aims to implement deep learning architectures that
are relevant to problems in cancer. These architectures address problems
at three biological scales: cellular (Pilot1 P1), molecular (Pilot P2)
and population (Pilot3).

Pilot1 (P1) benchmarks are formed out of problems and data at the
cellular level. The high level goal of the problem behind the P1
benchmarks is to predict drug response based on molecular features of
tumor cells and drug descriptors. Pilot2 (P2) benchmarks are formed out
of problems and data at the molecular level. The high level goal of the
problem behind the P2 benchmarks is molecular dynamic simulations of
proteins involved in cancer, specifically the RAS protein. Pilot3 (P3)
benchmarks are formed out of problems and data at the population level.
The high level goal of the problem behind the P3 benchmarks is to
predict cancer recurrence in patients based on patient related data.

Uno application from Pilot1 (P1): The goal of Uno is to predict tumor
response to single and paired drugs, based on molecular features of
tumor cells across multiple data sources. Combined dose response data
contains sources: \['CCLE' 'CTRP' 'gCSI' 'GDSC' 'NCI60' 'SCL' 'SCLC'
'ALMANAC.FG' 'ALMANAC.FF' 'ALMANAC.1A'\]. Uno implements a deep learning
architecture with 21M parameters in TensorFlow framework in Python. The
code is publicly available on
[GitHub](https://github.com/ECP-CANDLE/Benchmarks/tree/develop/Pilot1/Uno).
The script in this repository downloads all required datasets. The
primary metric to evaluate this applications is throughput (samples per
second). More details on running Uno can be found
[here](https://github.com/ECP-CANDLE/Benchmarks/blob/develop/Pilot1/Uno/README.AUC.md).

#### CANDLE-UNO Specific Benchmark Targets

1.  Scientific objective(s):
    -   Objective: Predictions of tumor response to drug treatments,
        based on molecular features of tumor cells and drug descriptors
    -   Formula: Validation loss
    -   Score: 0.0054
2.  Data
    -   Download:
        <http://ftp.mcs.anl.gov/pub/candle/public/benchmarks/Pilot1/uno/>
    -   Data Size: 6.4G
    -   Training samples: 423952
    -   Validation samples: 52994
3.  Example implementation
    -   Model: Multi-task Learning-based custom model
    -   Reference Code:
        <https://github.com/ECP-CANDLE/Benchmarks/tree/develop/Pilot1/Uno>
    -   Run Instructions:
        <https://github.com/ECP-CANDLE/Benchmarks/blob/develop/Pilot1/Uno/README.AUC.md>
    -   Time-to-solution: 10667 samples/sec (batch size 64) on single
        A100

