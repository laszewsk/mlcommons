
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
docker run -it --rm singularity:latest run docker://godlovedc/lolcow
```
