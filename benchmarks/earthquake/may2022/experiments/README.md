# Experiment templates

This directory contains a number of experiment templates allowing to setup and run the earthquak code.
We distinguish the following.

* rivanna-2epoch: runs a single experiement with 2 epochs to see how long a run will be and if the program works
* ubuntu-slurm: Assumes that you have slurm installed under ubuntu. It runs the 2 epoch case, 
  but it can be easily modified using parameters from rivanna

The following are under development:

* docker: under development. runs a parameterized run in docker, accessing the GU through docker
* dgxstation: under development. runs a parameterized run natively on an ubuntu based dgx station. 
* rivanna: under development. Runs an experiment parameter study on University of Virginias Rivanna
* summit: under development. runs a parameterized run on summit
* ubuntu.sh: under development. runs a parameterized run on a single ubuntu machine in bash. 
  Needs to be renamed to ubuntu.bash
