#!/bin/bash

# This reports on the diskspace specified in the first argument, as in:
# USAGE: 
#   curl -O https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/bash/folder-space.sh
#   chmod +x folder.space.sh
#   ./folder-space.sh ~/var/log
# RESPONSE:
#   38M   /var/log

# This is https://github.com/wilsonmar/DevSecOps/blob/master/bash/folder-space.sh
# Adapted from https://unix.stackexchange.com/questions/53841/how-to-use-a-timer-in-bash
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/bash/folder-space.sh)"

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# Capture starting timestamp:
   start=$(date +%s)

# Example: sleep $1

   # du -csh /data/registry/docker/registry
   echo "$ du -cs $1"
           du -cs $1
#           du -csh $1

# Capture endining timestamp:
   end=$(date +%s)

# Calculate difference:
   seconds=$(echo "$end - $start" | bc )
   #echo $seconds' sec'
   echo 'Elapsed: ' $( awk -v t=$seconds 'BEGIN{t=int(t*1000); printf "%d:%02d:%02d\n", t/3600000, t/60000%60, t/1000%60}' )
   
