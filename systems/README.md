# MLCommons Systems Configuration Code

In these folders there are system-specific configurations that help normalize the different HPC systems the mlcommons benchmarking programs.

## Enabling modules

To enable the custom lmod modules, run the command

```bash
SYSTEM_NAME="rivanna" # Replace with your HPC name
module use /path/to/repo/systems/$SYSTEM_NAME/modulefiles
```

Then all custom modules will be made available when loading modules.


### Current modules

The current listing of supported modules are:

* python-rivanna - `python-rivanna/3.10.2`, `python-rivanna/3.9.7`, `python-rivanna/3.8.5`
  * An optimized version of python compiled on rivanna
  * Assumes:
    * user has access to /project/ds6011-sp22-002 folder
    * buildscripts for the package has been previously executed

## Folder Structure

The folder structure is as follows

```text
systems
 |
 |--<system_name>                 # Name of the running systme cluster
 |    |
 |    |--modulefiles              # lmod modulefiles configured for system
 |    |   |
 |    |   |--<software_package_1> # module name
 |    |   |   |
 |    |   |   |--<version>.lua    # specific version of module
 |    |   |   |
 |    |   |   |-- (...)
 |    |   |   
 |    |   |--<software_package_2> # another lmod moduel file
 |    |   |   |-- (...)
 |    |   |-- (...)
 |    |
 |    |--buildscripts             # Folder container scripts to build packages on enviornment
 |        |
 |        |--<software_package_1> # buildscripts for software_package_1
 |            |
 |            |--<project files>
 |            |
 |            |-- (...)
 |-- (...)
```
