# slurm docker

```bash
cd ~/cm
git clone https://github.com/giovtorres/slurm-docker-cluster.git
cd slurm-docker-cluster/
docker build -t slurm-docker-cluster:21.08.6 .
IMAGE_TAG=19.05.2 docker-compose up -d
./register_cluster.sh
docker exec -it slurmctld bash
```

```bash
sinfo
cd /data
sbatch --wrap="hostname"
cat slurm-1.out
```