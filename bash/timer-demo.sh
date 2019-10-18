#!/bin/bash

# ./timer-demo.sh in https://github.com/wilsonmar/DevSecOps/blob/master/bash/timer-demo.sh
# Adapted from https://unix.stackexchange.com/questions/53841/how-to-use-a-timer-in-bash
# USAGE:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/bash/timer-demo.sh)"

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

start=$(date +%s)
#
# do something
sleep $1

# du -csh /data/registry/docker/registry
# du -csh ~/gits
#
#
end=$(date +%s)

seconds=$(echo "$end - $start" | bc )
# echo $seconds' sec'
echo 'Elapsed: '
awk -v t=$seconds 'BEGIN{t=int(t*1000); printf "%d:%02d:%02d\n", t/3600000, t/60000%60, t/1000%60}'
