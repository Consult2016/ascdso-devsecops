#!/usr/bin/env bash

# install.sh in https://githuben.mckinsey.com/wilsonmar/dev-bootcamp
# This downloads and installs all the utilities, then verifies.
# After getting into the Cloud9 enviornment,
# cd to folder, copy this line and paste in the Cloud9 terminal:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/bash/hello.sh)"
# bash -c "$(curl -fsSL https://githuben.intranet.mckinsey.com/raw/Wilson-Mar/dev-bootcamp/master/hello.sh)"

### STEP 1. Set display utilities:

clear  # screen (but not history)

#set -eu pipefail  # pipefail counts as a parameter
# set -x to show commands for specific issues.
# set -o nounset
# set -e  # to end if 

# TEMPLATE: Capture starting timestamp and display no matter how it ends:
EPOCH_START="$(date -u +%s)"  # such as 1572634619
FREE_DISKBLOCKS_START="$(df -k . | cut -d' ' -f 6)"  # 910631000 Available

trap this_ending EXIT
trap this_ending INT QUIT TERM
this_ending() {
   echo "_"
   EPOCH_END=$(date -u +%s);
   DIFF=$((EPOCH_END-EPOCH_START))

   FREE_DISKBLOCKS_END="$(df -k . | cut -d' ' -f 6)"
   DIFF=$(((FREE_DISKBLOCKS_START-FREE_DISKBLOCKS_END)))
   MSG="End of script after $((DIFF/360)) minutes and $DIFF bytes disk space consumed."
   #   info 'Elapsed HH:MM:SS: ' $( awk -v t=$beg-seconds 'BEGIN{t=int(t*1000); printf "%d:%02d:%02d\n", t/3600000, t/60000%60, t/1000%60}' )
   success "$MSG"
   #note "$FREE_DISKBLOCKS_START to 
   #note "$FREE_DISKBLOCKS_END"
}
sig_cleanup() {
    trap '' EXIT  # some shells call EXIT after the INT handler.
    false # sets $?
    this_ending
}

### Set color variables (based on aws_code_deploy.sh): 
bold="\e[1m"
dim="\e[2m"
underline="\e[4m"
blink="\e[5m"
reset="\e[0m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"
cyan="\e[36m"

h2() {     # heading
  printf "\n${bold}>>> %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
info() {   # output on every run
  printf "${dim}\n➜ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
RUN_VERBOSE=false
note() { if [ "${RUN_VERBOSE}" = true ]; then
   printf "${bold}${cyan} ${reset} ${cyan}%s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
   fi
}
success() {
  printf "${green}✔ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
error() {
  printf "${red}${bold}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
warnNotice() {
  printf "${cyan}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
warnError() {
  printf "${red}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}

info "Bash $BASH_VERSION"
# Check what operating system is used now.
if [ "$(uname)" == "Darwin" ]; then  # it's on a Mac:
   OS_TYPE="macOS"
elif [ -f "/etc/centos-release" ]; then
   OS_TYPE="CentOS"  # for yum
elif [ -f $( "lsb_release -a" ) ]; then  # TODO: Verify this works.
   OS_TYPE="Ubuntu"  # for apt-get
else 
   error "Operating system not anticipated. Please update script. Aborting."
   exit 0
fi
HOSTNAME=$( hostname )
PUBLIC_IP=$( curl -s ifconfig.me )
info "OS_TYPE=$OS_TYPE on hostname=$HOSTNAME at PUBLIC_IP=$PUBLIC_IP."

