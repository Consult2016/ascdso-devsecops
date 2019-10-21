#!/bin/bash

# This reports on the diskspace specified in the first argument, as in:
# USAGE: ./folder-space.sh ~/var

# This is https://github.com/wilsonmar/DevSecOps/blob/master/bash/folder-space.sh
# Adapted from https://unix.stackexchange.com/questions/53841/how-to-use-a-timer-in-bash
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/bash/folder-space.sh ~/var)"
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

set -euxo pipefail

if [ $# -ne 2 ]; then
   echo "Please provide 2 arguments: USAGE: ./folder-space.sh /folder START_BYTES"
   exit 
fi

# Verify folder is present:
if [ ! -d "$1" ]; then # NOT found:
   printf ">>> Folder %s not found!\n" "$1"
   exit
fi

# Capture starting timestamp:
   start=$(date +%s)

         # du -csh /data/registry/docker/registry
   #echo "$ du -csh $1" (-h for human-readable)
   BYTES=$( du -cs "$1" | head -n 1 | cut -f1 )

# Capture ending timestamp:
   end=$(date +%s)

   # Calculate difference:
   seconds=$( echo "$end - $start" | bc )
   #echo $seconds' sec'
   echo 'Elapsed seconds: ' $( awk -v t=$seconds 'BEGIN{t=int(t*1000); printf "%d:%02d:%02d\n", t/3600000, t/60000%60, t/1000%60}' )

   # Save to a file for retrieval:
   rm -rf .$2
   echo "$BYTES" > .$2
   ls -al .$2
   echo ">>> BYTES: " $( cat .$2 )
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
   
