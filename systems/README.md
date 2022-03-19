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

* python-rivanna - `python-rivanna/3.10.3`, `python-rivanna/3.10.2`, `python-rivanna/3.9.7`, `python-rivanna/3.8.5`
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

## References

For more details on the lua environment module system `lmod`, see <https://lmod.readthedocs.io/en/latest/index.html>.

The following pages are useful when building your own modulefiles.

* <https://lmod.readthedocs.io/en/latest/015_writing_modules.html>
* <https://lmod.readthedocs.io/en/latest/020_advanced.html>

Note that lmod assumes you are familiar with lower-level system design components and know how to reconfigure your programs to use portable shared libraries (explained in [`ld.so`](https://man7.org/linux/man-pages/man8/ld.so.8.html) ).

However, lmod not only can bootstrap tools, but it can do additional setup tasks such as setting environment variables, nested module loading, defining shell alias commands, and also perform additional bootstrapping written in lua.

For the full API, check the [Lmod](https://lmod.readthedocs.io/en/latest/050_lua_modulefiles.html) website.
