#!/bin/bash


echo "Cleaning cloudModels"
rm -rf card_name_*_gpu_count*

echo "Cleaning outputs/ and outputs    ..."
rm -f outputs/rg3515*
rm -f outputs/gpu*
rm -f outputs/*.h5

echo "Cleaning __pycache__  ..."
rm -rf __pycache__/

echo "Cleaning mlperf_cloudmask logs    ..."
rm -f mlperf_cloudmask*.log

echo "Cleaning cloudmask logs    ..."
rm -f cloudmask_*.log

echo "Cleaning Reproduce Config/Slurm Directory..."
rm -rf config_reproduce_files
rm -rf slurm_reproduce_files

#echo "Cleaning Directory..."
echo "Cleaning Completed."
