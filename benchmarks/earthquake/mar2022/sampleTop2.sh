#! /bin/bash
# This script takes three command line arguments, samples the output of the top command
# and stores the output of the sampling in the file named Top.out.
# $1 is the user ID of the owner of the processes to sample from the top output
# $2 is the name  to include in the top output filename
# $3 is the top sampling interval
# Example of line to include in slurm script submission before executable invoked
# ./sampleTop.sh teh1m <filename> 5 & 
# Remember to run this script in the background using &

module load gcc/9.2.0 openmpi/3.1.6 gpustat

topOut="Top_$2.out"
 # name of file to store output of top

clockOut="Clock_$2.out"
 # name of file to store output of top

userID=$1   # user ID to check for

let maxIter=3000000000   # maximum number of loop iterations to run top
let nprocs=0    # variable to check if process associated with $ has started yet


# loop to check to see if process has started yet
checkTop=$(top -n 1 -u "$userID" -b | egrep  "$userID" | wc -l)
let iter=1
while [ $checkTop -eq $nprocs -a  $iter -lt $maxIter ];
do
  date >> $topOut
  sleep ${3} 
  checkTop=$(top -n 1 -u "$userID" -b | egrep   "$userID" | wc -l)
let iter=iter+1;
done

# once process has started, loop to sample output of top 
let iter=1
while [ $checkTop -gt $nprocs -a  $iter -lt $maxIter ];
do
#  date >> $clockOut
#  cat /proc/cpuinfo | grep "cpu MHz" >> $clockOut
  date >> $topOut
  #top -H -i -n 1 -u "$userID" -b >> $topOut
  top -i -n 1 -u "$userID" -b >> $topOut
  echo " " >>$topOut
  
  if [[ "$SLURM_JOB_PARTITION" == "gpu" ]]
  then
  date >> "gpustat_$2.out"
  hostname >> "gpustat_$2.out"
  #gpustat --no-color | egrep "$userID"   >> "gpustat_$2.out"
  gpustat --no-color    >> "gpustat_$2.out"
  echo " " >> "gpustat_$2.out"
  fi

  sleep ${3}
  checkTop=$(top -n 1 -u "$userID" -b | egrep   "$userID" | wc -l)

let iter=iter+1;
done
exit
