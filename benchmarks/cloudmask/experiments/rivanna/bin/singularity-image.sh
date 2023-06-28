#! /bin/sh -x
export SINGULARITY_CACHEDIR=/scratch/$USER/.singularity/
mkdir -p $SINGULARITY_CACHEDIR
NAME=$1

start_total=`date +%s`
cp ${NAME}.def build.def
sudo /opt/singularity/3.7.1/bin/singularity build output_image.sif build.def
cp output_image.sif ${NAME}.sif
# make -f Makefile clean
end_total=`date +%s`
time_total=$((end_total-start_total))
echo "Time for image build: ${time_total} s"
