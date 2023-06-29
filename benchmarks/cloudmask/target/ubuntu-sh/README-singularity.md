# Build

Create the image with 

```
make simage
```

| Machine | Filesystem | Stage      | Time       | Time in s |
|---------|------------|------------|------------|-----------|
| amd     | home       | downloaded | 3m 20.396s | 200.396   |
| amd     | home       | new        | 5m 1.565s  | 301.565   |
| rivanna | /scratch   | downloaded | 4m 49s     | 289       |
| rivanna | /scratch   | new        |            |           |


To delete the image and all singularity cache say 



```
make sclean
```

# Shell

To run a shell in the image say 

```
make shell
```

# Run

To run a shell in the image say 

```
make run
```
