#!/bin/bash

# This reports on the diskspace specified in the first argument, as in:
# USAGE: 
#   curl -O https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/bash/cmd-space-delta.sh
#   chmod +x folder.space.sh
#   ./cmd-space-delta.sh ~/var/log
# RESPONSE:
#   38M   /var/log

# This is https://github.com/wilsonmar/DevSecOps/blob/master/bash/cmd-space-delta.sh
# Adapted from https://unix.stackexchange.com/questions/53841/how-to-use-a-timer-in-bash
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/bash/cmd-space-delta.sh)"

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


### 0. Set display utilities:
clear  # screen and history?

### Set color variables (based on aws_code_deploy.sh): 
bold="\e[1m"
dim="\e[2m"
underline="\e[4m"
blink="\e[5m"
reset="\e[0m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"

h2() {
  printf "\n${bold}>>> %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
info() {
  printf "${dim}➜ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
success() {
  printf "${green}✔ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
error() {
  printf "${red}${bold}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
warnError() {
  printf "${red}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
warnNotice() {
  printf "${blue}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
note() {
  printf "\n${bold}${blue}Note:${reset} ${blue}%s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}


h2 "4. Pre-requisites installation:"
command_exists() {  # in /usr/local/bin/... if installed by brew
  command -v "$@" > /dev/null 2>&1
}


# What operating system:

# Install jq
# If centos or RHEL:
#   yum install -y epel-release
#   yum install -y jq

   # Otherwise
   #   wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
   #   chmod +x ./jq
   #   cp jq /usr/bin



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
   beg-seconds=$(echo "$end - $start" | bc )
   #echo $seconds' sec'
   echo 'Elapsed: ' $( awk -v t=$beg-seconds 'BEGIN{t=int(t*1000); printf "%d:%02d:%02d\n", t/3600000, t/60000%60, t/1000%60}' )

# Store bytes for use outside this script:
# ???



h2 "STEP 1 - Check if account/image/tag has already been removed..."
# ??? Error Message: "account/image/tag already deleted"

h2 "STEP 2 - Obtain starting space: "
./folder.space.sh  $1  START_BYTES

h2 "STEP 3 - Get account/image:tag SHA"
# OH_SHA=$( docker inspect dev-registry-1x01.amdc.mckinsey.com:5000/pythonapi:9254c0d )
# MY_SHA=jq ??? "$OH_SHA"

h2 "STEP 4 - Remove layers ..."
# Do one:
   # curl -v -X DELETE "https://my.docker.registry.com:5000/v2/mytestdockerrepro/manifests/$MY_SHA" )
      # Expect 202 good response

h2 "STEP 5 - Obtain space after removing layers (should be same):"
./folder.space.sh $1  MID_BYTES


h2 "STEP 6 - Garbage collection to reclaim disk space ..."
# docker exe registry bin/registry garbage-collect --dry-run /etc/docker/registry/config.yml

h2 "STEP 7 - Obtain end-space:"
./folder.space.sh  $1  END_BYTES 


h2 "STEP 8 - Calculate space delta ..."
# START_BYTES - END_BYTES 

h2 "STEP 9 - De-gas storage units to reduce fragmentation ..."
# ???

h2 "STEP 10 - Obtain final space ..."
./folder.space.sh $1 FINAL_BYTES 

h2 "STEP 11 - Calculate final space delta ..."
# START_BYTES - FINAL_BYTES 


