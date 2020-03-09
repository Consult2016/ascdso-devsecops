#!/bin/bash
# This is bash-parms.sh
# From https://stackoverflow.com/questions/7069682/how-to-get-arguments-with-flags-in-bash/7069755#7069755
# No editing of this file is needed, as
# this is an example of how to accept gnu-style parameters such as --help as well as 
# single character ones recognized by getopts

# In the code below:
# $# is the Bash built-in variable for the number of arguments provided
# The while loop cycles through the arguments supplied, matching on their values inside a case statement.
# The shift command removes the first argument so the next one is processed through the while loop.

# Run several ways:
# $ chmod +x bash-parms.sh
# No response is returned from the break command in the code
# $ ./bash-parms.sh 
# $ ./bash-parms.sh -h
# $ ./bash-parms.sh --help
# $ ./bash-parms.sh -a
# etc.


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
  printf "\n${bold}${cyan}Note:${reset} ${cyan}%s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}


package="$0"
echo "here $package"
args_prompt() {
   echo "$package - something --------------------------------------------"
   echo " "
   echo "$package [options] application [arguments]"
   echo " "
   echo "options:"
   echo "-h, --help                show brief help"
   echo "-a, --action=ACTION       specify an action to use"
   echo "-o, --output-dir=DIR      specify a directory to store output in"
   echo "-v                        verbose output for debugging"
}
if [ "$#" -eq 0 ]; then 
#   error "No arugments provided in command call."
   args_prompt
fi
while test $# -gt 0; do
  case "$1" in
    -h|--help)
      args_prompt
      exit 0
      ;;
    -v)
      VERBOSE=true
      ;;
    -a)
      shift
      if test $# -gt 0; then
        export PROCESS=$1
      else
        echo "no process specified"
        exit 1
      fi
      shift
      ;;
    --action*)
      export PROCESS=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    -o)
      shift
      if test $# -gt 0; then
        export OUTPUT=$1
      else
        echo "no output dir specified"
        exit 1
      fi
      shift
      ;;
    --output-dir*)
      export OUTPUT=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    *)
      break
      ;;
  esac
done
