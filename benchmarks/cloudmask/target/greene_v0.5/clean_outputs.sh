#!/bin/bash

echo "Cleaning outputs/     ..."
rm -f outputs/rg3515*
rm -f outputs/gpu*

echo "Cleaning __pycache__  ..."
rm -rf __pycache__/

echo "Cleaning mlperf_cloudmask logs    ..."
rm -f mlperf_cloudmask*

echo "Cleaning cloudmask logs    ..."
rm -f cloudmask_*_epoch*

echo "Cleaning Reproduce Config/Slurm Directory..."
rm -rf config_reproduce_files
rm -rf slurm_reproduce_files

#echo "Cleaning Directory..."
#echo "Cleaning Directory..."
#echo "Cleaning Directory..."
echo "Cleaning Completed."
