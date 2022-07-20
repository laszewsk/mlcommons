# Rivanna Modules

## Python

As of July 2022, the script located in
[buildscripts/python-rivanna/compile-python.bash](./buildscripts/python-rivanna/compile-python.bash)
contains a fully automated process to build python from versions 3.8 to 3.10. With future
releases, you may need to select a more modern version of OpenSSL, or change the way how
the `compile_python` function works to support additional build flags.

### What the buildscript does

This script:
1. Downloads and compiles OpenSSL 1.1.1m.
   * Rivanna's version of OpenSSL is too old for modern python compilations.
   * This is compiled in a portable way where it is not installed systemwide
     allowing us to use an independent version of OpenSSL from the rest of the rivanna cluster.
2. Downloads and compiles Python at a specified version
   * This version of python has optimistic compilations enabled (lto, computed-gotos, system-ffi),
     which are known to be safe optimization techniques to be used for general purpose execution.
   * This compilation uses all cores of the source machine to make sure it is built as efficently
     as possible.
   * The compilation process expliticly references the OpenSSL compilation before it as a dependency.
     This is necessary because the default path for OpenSSL on rivanna refers to a version that is
     too old.
   * This compilation also performs the standard python testing to ensure that it builds and exeutes
     as intended.  You may see some errors regarding parallel execution, which is normal.  If python
     behaves unexpectedly during the testing, the make process will fail to complete with a non-zero
     exit code.

### General Update Flow

The general flow of setting up python using these scripts are as follows

1. Clone this repo
2. Navigate to the folder [mlcommons/systems/rivanna/buildscripts/python-rivanna](./buildscripts/python-rivanna).
3. Open the [compile-python.bash](./buildscripts/python-rivanna/compile-python.bash) script.
   1. If not installing to the bii_dsc project folder, update the `BASE` variable to be your
      destination path.  Record this path for later, as you will need to update the lmod files
      to represent the updated path.
   2. At the end of the file add a line `build_python <python_version> ${BASE} ${BASE}`, where
      `<python_version>` is the 3-position version for python.
   4. Note - you can compile multiple versions at once by adding additional lines.  Note that it
      will compile each line from scratch, regardless if you have compiled it before.  The
      default file has all known working versions of python added.
4. Once the compilation is complete, copy the [mlcommons/systems/rivanna/modulefiles/](./modulefiles),
   so that `python-rivanna` folder is in a destination your group has read and execute access to.
   1. If you modified the `BASE` path, you will need to go into each of the versioned
      [python-rivanna](./mlcommons/systems/rivanna/modulefiles) files (i.e. `3.8.5.lua`), and update
      the `workspace` variable to be the path that contains the folders `python/base`.
      For example `BASE="/project/bii_dsc/mlcommons-system/python/base"` is `local workspace = "/project/bii_dsc/mlcommons-system"`
   2. If you are adding a new version of python
      1. Copy any existing \*.lua file in this directory with the name `<python_version>.lua`
      2. Open the file and replace all references to the original version with the newer `<python_version>`.
         This is typically only in the `help` block near the top. 
      4. Place it in the targeted modulefiles directory.
5. Once complete, you can now use the newer version of python by running
   ```bash
   module use </path/to/module>
   module load python-rivanna/<python_version>
   ```
   Optionally, you can omit the `/<python_version>` and it will use the latest semantic version in
   the directory lmod finds.
