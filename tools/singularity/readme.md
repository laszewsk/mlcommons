
# Singularity in Docker

If you wish to run singularity as a container image instead of installing it directly on your system, you can use the following procedure to get an image build.

```bash
# If using docker
docker build -t singularity:latest .

# If using nerdctl
nerdctl image build --tag singularity .
```

To run singularity from this, you can pass command line arguments as you normally would for the singularity CLI.

```bash
# If using docker
docker run -it --rm --privileged singularity:latest run docker://godlovedc/lolcow

# If using nerdctl
nerdctl run -it --rm --privileged singularity:latest run docker://godlovedc/lolcow
```

NOTE: It is **very** important that you add the `--privileged` flag if you want to run containers within containers.
By default, docker and nerdctl prevent containers from spawning containers as a security measure to help prevent a container from escaping its processing space.
This happens through security labeling of the runtime known as [Capabilities](https://linux-audit.com/linux-capabilities-101/).
However, since we are deliberately running a container within a container, this protection would prevent us from running a singularity container within a docker container.
By adding the `--privileged` flag, you are instructing your container runtime to disable this capability labeling, which enables the ability to run singularity within the container, but also reduces the isolation of the container runtime.

It's recommended you only run containers you trust using the `--privileged` flag.
