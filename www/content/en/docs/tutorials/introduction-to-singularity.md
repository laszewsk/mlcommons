---
title: "Installing Singularity on Windows Workstations"
linkTitle: "Singularity@everywhere"
author: Robert Knuuti
date: 2022-02-06
weight: 4
description: >
  A procedure to get singularity running on WSL2
---

Singularity is a container-based runtime engine designed to run in permission constrained environments.
Singularity provides similar functions to systems like Docker, Containerd, and Podman, and provides an ecosystem to share a computer's kernel and drivers and provide a filesystem based on overlaying files.
These overlays create a type of partitioned software that that can create isolated execution on the host as a type of "container".

However, Singularity differs from typical container runtime engine, most notably:

1. Singularity was designed to be run as a normal, non-root user and does not depend on a daemon.
2. Singularity does not natively support OCI images (the typical container image format target), and uses its own SIF format; but OCI images can be imported.
3. Singularity container images are distributed as files.
4. Singularity was designed to create a container platform that works from laptops to HPC clusters.

## (Windows Only) Setup on Window Subsystem for Linux

While not the normal place to install singularity, it is useful to have the ability to run commands from a local machine to validate command structure and workflows.
Singularity does not run natively on windows, but with Windows 10 Professional, you can build Singularity using a WSL2 distribution and provide the ability to run the commands on your workstation.

### Enabling WSL2

To enable WSL2, follow microsoft's instructions

* Windows 10/11 - https://docs.microsoft.com/en-us/windows/wsl/install
* Windows 10 older than 2004 - https://docs.microsoft.com/en-us/windows/wsl/install-manual

Any version of linux will work with Singularity, but we recommend using Ubuntu.

## Building Singularity

This process has been automated in `./tools/install-singularity-wsl2.bash` if you're running Ubuntu.
However, the general flow of the instruction is:

1. Install the singularity code dependencies (gcc, libssl, gpgme, squashfs, seccomp, wget, pkg-config, git, and cryptsetup)
2. Install a modern version of golang.
3. Download the Singularity source code from https://github.com/apptainer/singularity.git
4. Run `./mconfig` from the singularity codebase
5. Run `make && make install` from the `./builddir` directory.

These procedures are more thoroughly covered in the apptainer website at: https://apptainer.org/docs/user/main/quick_start.html#quick-installation-steps

### Run your first singularity container

Once the build has completed, you should be able to run the `singularity` command.
Try to run

```bash
$ singularity run docker://godlovedc/lolcow
```

If this command was successful you should see something similar to the following:

```text
 _____________________________________
/ You recoil from the crude; you tend \
\ naturally toward the exquisite.     /
 -------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```
