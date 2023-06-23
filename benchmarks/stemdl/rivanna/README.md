
# Stem DL

Final Production https://github.com/mlcommons/science/tree/main/benchmarks/stemdl

Dev Repo        https://github.com/laszewsk/mlcommons/tree/main/benchmarks/stemdl

## Datasets:
Preprocessed data - Size:18GB Name:sgdata.tar

Non preprocessed Data - Size: 540GB 10.13139_OLCF_1510313.tar

## Commands to time and extract data

time tar -xf sgdata.tar.gz > time-sgdata.txt &

time tar -xf 10.13139_OLCF_1510313.tar >time-big.txt &


## What I have done:
-[X] Import processed Data into rivanna 
Import unprocessed data into rivanna (30 mins to download 540gb through globus project/bii_dsc_community/qft2jk/stemdl/data)

-[X] Take a look at rclone in infomall (rclone configured)

-[X] Set up rclone


# To do:
- [not complete] set up cloudmesh-vpn




- [not complete]Configure cloudmesh-vpn
openssl pkcs12 -in mst3k.p12 -nocerts -nodes -out mst3k.key
openssl pkcs12 -in mst3k.p12 -clcerts -nokeys -out mst3k.crt
openssl x509 -inform DER -in usher.cer -out usher.crt

- Commands above are not working and certification wont work. (Could not read certificate from usher.cer Unable to load certificate)

- Update Rclone tutorial

- Use rclone to extract preprocessed data from shared drive to rivanna

- Configure cloudmesh

- Run initial benchmarks of the project which are found in infomall


