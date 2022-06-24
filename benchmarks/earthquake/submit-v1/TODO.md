
1. Migrate the minimum from the latest code base
2. Provide instructions without necessarily including the experiment
3. Goal: a single document to run a "single" benchmark.
   1. Add the experiments that currently work
4. These procedures should be "generic" to run anywhere


Augment stopwatch with these params
https://github.com/mlcommons/science/blob/main/benchmarks/cloudmask/slstr_cloud.py#L187-L192
and
https://github.com/mlcommons/science/blob/main/benchmarks/cloudmask/slstr_cloud.py#L221-L224

192 and 197 are the most critical.

consider adding constants into the timer for the bootstrapping of the mlperf functions (and add to StopWatch).
(Dictionary as a parameter within the stopwatch class?)
https://github.com/mlcommons/science/blob/main/benchmarks/cloudmask/slstr_cloud.py#L187-L191




Maybe extend an existing Readme (use a generated output from an experiment folder)
(run without bash)

https://github.com/mlcommons/science

^ This needs to be augmented into our resources

look at https://github.com/mlcommons/science/tree/main/benchmarks/cloudmask for reference on the readme.


requirements.txt install
setting up yaml file
setup of data directory
running of papermill
interp results