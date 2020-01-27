#!/usr/bin/env bash
# shellcheck disable=SC2001 # See if you can use ${variable//search/replace} instead.
# shellcheck disable=SC1090 # Can't follow non-constant source. Use a directive to specify location.

# ruby-install.sh in https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/bash/ruby-install.sh
# coded based on bash scripting techniques described at https://wilsonmar.github.io/bash-scripting.

# This downloads and installs all the utilities, then invokes programs to prove they work
# This was run on macOS Mojave and Ubuntu 16.04.

# After you obtain a Terminal (console) in your enviornment,
# cd to folder, copy this line and paste in the terminal:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/bash/ruby-install.sh)" -v -E -i

SCRIPT_VERSION="v0.39"
clear  # screen (but not history)
echo "================================================ $SCRIPT_VERSION "

# Capture starting timestamp and display no matter how it ends:
EPOCH_START="$(date -u +%s)"  # such as 1572634619
LOG_DATETIME=$(date +%Y-%m-%dT%H:%M:%S%z)-$((1 + RANDOM % 1000))


# Ensure run variables are based on arguments or defaults ..."
args_prompt() {
   echo "USAGE EXAMPLE during testing:"
   echo "./ruby-install.sh -v -E -i -o  # Ruby app"   
   echo "./ruby-install.sh -v -E -I -U -c -s -r -a -o  # Python app"
   echo "USAGE EXAMPLE after testing:"
   echo "./ruby-install.sh -v -D -M -C"
   echo "OPTIONS:"
   echo "   -E           to set -e to stop on error"
   echo "   -v           to run -verbose (list space use and each image to console)"
   echo "   -i           -install Ruby and Refinery"
   echo "   -I           -Install brew, docker, docker-compose"
   echo "   -U           -Upgrade packages"
   echo "   -c           -clone from GitHub"
   echo "   -s           Use -secrets file in your user home folder"
   echo "   -n \"$USER\"            GitHub user -name"
   echo "   -e \"$USER@corp.com\"   GitHub user -email"
   echo "   -P \" \"    Project folder -path "
   echo "   -r           -start Docker before run"
   echo "   -a           to -actually run docker-compose"
#   echo "   -t           to run -tests"
   echo "   -o           to -open web page in default browser"
   echo "   -D           to -Delete files after run (to save disk space)"
   echo "   -M           to remove Docker iMages pulled from DockerHub"
   echo "   -C           to remove -Cloned files after run (to save disk space)"
   echo " "
 }
if [ $# -eq 0 ]; then  # display if no parameters are provided:
   args_prompt
   exit 1
fi
exit_abnormal() {            # Function: Exit with error.
  echo "exiting abnormally"
  #args_prompt
  exit 1
}

# Defaults (default true so flag turns it true):
   SET_EXIT=false               # -E
   RUN_VERBOSE=false            # -v
   RUBY_INSTALL=false           # -i
   UPDATE_PKGS=false            # -U
   RESTART_DOCKER=false         # -r
   RUN_ACTUAL=false             # -a  (dry run is default)
   DOWNLOAD_INSTALL=false       # -d
   RUN_DELETE_AFTER=false       # -D
   RUN_OPEN_BROWSER=false       # -o
   CLONE_GITHUB=false           # -c
   REMOVE_GITHUB_AFTER=false    # -R
   USE_SECRETS_FILE=false       # -s
   REMOVE_DOCKER_IMAGES=false   # -M
   RUBY_INSTALL=false

SECRETS_FILEPATH="$HOME/.secrets.sh"  # -S
PROJECT_FOLDER_PATH="$HOME/projects"  # -P

GitHub_USER_NAME=""                  # -n
GitHub_USER_EMAIL=""                 # -e
GitHub_REPO_NAME="bsawf"

#DOCKER_DB_NANE="snakeeyes-postgres"
#DOCKER_WEB_SVC_NAME="snakeeyes_worker_1"  # from docker-compose ps  
#APPNAME="snakeeyes"
APPNAME="rockstar"

while test $# -gt 0; do
  case "$1" in
    -v)
      export RUN_VERBOSE=true
      shift
      ;;
    -i)
      export RUBY_INSTALL=true
      shift
      ;;
    -E)
      export SET_EXIT=true
      shift
      ;;
    -I)
      export DOWNLOAD_INSTALL=true
      shift
      ;;
    -U)
      export UPDATE_PKGS=true
      shift
      ;;
    -c)
      export CLONE_GITHUB=true
      shift
      ;;
    -n*)
      shift
      # shellcheck disable=SC2034 # ... appears unused. Verify use (or export if used externally).
             GitHub_USER_NAME=$( echo "$1" | sed -e 's/^[^=]*=//g' )
      export GitHub_USER_NAME
      shift
      ;;
    -e*)
      shift
             GitHub_USER_EMAIL=$( echo "$1" | sed -e 's/^[^=]*=//g' )
      export GitHub_USER_EMAIL
      shift
      ;;
    -p*)
      shift
             PROJECT_FOLDER_PATH=$( echo "$1" | sed -e 's/^[^=]*=//g' )
      export PROJECT_FOLDER_PATH
      shift
      ;;
    -s)
      export USE_SECRETS_FILE=true
      shift
      ;;
    -S*)
      shift
             SECRETS_FILEPATH=$( echo "$1" | sed -e 's/^[^=]*=//g' )
      export SECRETS_FILEPATH
      shift
      ;;
    -r)
      export RESTART_DOCKER=true
      shift
      ;;
    -a)
      export RUN_ACTUAL=true
      shift
      ;;
    -o)
      export RUN_OPEN_BROWSER=true
      shift
      ;;
    -D)
      export RUN_DELETE_AFTER=true
      shift
      ;;
    -M)
      export REMOVE_DOCKER_IMAGES=true
      shift
      ;;
    -C)
      export REMOVE_GITHUB_AFTER=true
      shift
      ;;
    *)
      error "Parameter \"$1\" not recognized. Aborting."
      exit 0
      break
      ;;
  esac
done


### Set ANSI color variables (based on aws_code_deploy.sh): 
bold="\e[1m"
dim="\e[2m"
# shellcheck disable=SC2034 # ... appears unused. Verify use (or export if used externally).
underline="\e[4m"
# shellcheck disable=SC2034 # ... appears unused. Verify use (or export if used externally).
blink="\e[5m"
reset="\e[0m"
red="\e[31m"
green="\e[32m"
# shellcheck disable=SC2034 # ... appears unused. Verify use (or export if used externally).
blue="\e[34m"
cyan="\e[36m"

h2() {     # heading
   printf "\n${bold}>>> %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
info() {   # output on every run
   printf "\n${dim}\n➜ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
note() { if [ "${RUN_VERBOSE}" = true ]; then
   printf "\n${bold}${cyan} ${reset} ${cyan}%s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
   fi
}
success() {
   printf "\n${green}✔ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
error() {    # &#9747;
   printf "\n${red}${bold}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
warning() {  # &#9758; or &#9755;
   printf "\n${cyan}☞ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
fatal() {   # Skull: &#9760;  # Star: &starf; &#9733; U+02606  # Toxic: &#9762;
   printf "\n${red}☢  %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}

# Check what operating system is in use:
   OS_TYPE="$( uname )"
   OS_DETAILS=""  # default blank.
if [ "$(uname)" == "Darwin" ]; then  # it's on a Mac:
      OS_TYPE="macOS"
      PACKAGE_MANAGER="brew"
elif [ "$(uname)" == "Linux" ]; then  # it's on a Mac:
   if command -v lsb_release ; then
      lsb_release -a
      OS_TYPE="Ubuntu"
      # TODO: OS_TYPE="WSL" ???
      PACKAGE_MANAGER="apt-get"

      silent-apt-get-install(){  # see https://wilsonmar.github.io/bash-scripts/#silent-apt-get-install
         if [ "${RUN_VERBOSE}" = true ]; then
            info "apt-get install $1 ... "
            sudo apt-get install "$1"
         else
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq "$1" < /dev/null > /dev/null
         fi
      }
   elif [ -f "/etc/os-release" ]; then
      OS_DETAILS=$( cat "/etc/os-release" )  # ID_LIKE="rhel fedora"
      OS_TYPE="Fedora"
      PACKAGE_MANAGER="yum"
   elif [ -f "/etc/redhat-release" ]; then
      OS_DETAILS=$( cat "/etc/redhat-release" )
      OS_TYPE="RedHat"
      PACKAGE_MANAGER="yum"
   elif [ -f "/etc/centos-release" ]; then
      OS_TYPE="CentOS"
      PACKAGE_MANAGER="yum"
   else
      error "Linux distribution not anticipated. Please update script. Aborting."
      exit 0
   fi
else 
   error "Operating system not anticipated. Please update script. Aborting."
   exit 0
fi
note "OS_DETAILS=$OS_DETAILS"


BASH_VERSION=$( bash --version | grep bash | cut -d' ' -f4 | head -c 1 )
   if [ "${BASH_VERSION}" -ge "4" ]; then  # use array feature in BASH v4+ :
      DISK_PCT_FREE=$(read -d '' -ra df_arr < <(LC_ALL=C df -P /); echo "${df_arr[11]}" )
      FREE_DISKBLOCKS_START=$(read -d '' -ra df_arr < <(LC_ALL=C df -P /); echo "${df_arr[10]}" )
   else
      if [ "${UPDATE_PKGS}" = true ]; then
         h2 "Bash version ${BASH_VERSION} too old. Upgrading to latest ..."
         if [ "${PACKAGE_MANAGER}" == "brew" ]; then
            brew install bash
         elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
            silent-apt-get-install "bash"
         elif [ "${PACKAGE_MANAGER}" == "yum" ]; then    # For Redhat distro:
            sudo yum install bash      # please test
         elif [ "${PACKAGE_MANAGER}" == "zypper" ]; then   # for [open]SuSE:
            sudo zypper install bash   # please test
         fi
         info "Now at $( bash --version  | grep 'bash' )"
         fatal "Now please run this script again now that Bash is up to date. Exiting ..."
         exit 0
      else   # carry on with old bash:
         DISK_PCT_FREE="0"
         FREE_DISKBLOCKS_START="0"
      fi


trap this_ending EXIT
trap this_ending INT QUIT TERM
this_ending() {
   EPOCH_END=$(date -u +%s);
   EPOCH_DIFF=$((EPOCH_END-EPOCH_START))
   if [ "${BASH_VERSION}" -lt "4" ]; then
      FREE_DISKBLOCKS_END="0"
   else
      FREE_DISKBLOCKS_END=$(read -d '' -ra df_arr < <(LC_ALL=C df -P /); echo "${df_arr[10]}" )
   fi
   FREE_DIFF=$(((FREE_DISKBLOCKS_END-FREE_DISKBLOCKS_START)))
   MSG="End of script $SCRIPT_VERSION after $((EPOCH_DIFF/360)) seconds and $((FREE_DIFF*512)) bytes on disk."
   # echo 'Elapsed HH:MM:SS: ' $( awk -v t=$beg-seconds 'BEGIN{t=int(t*1000); printf "%d:%02d:%02d\n", t/3600000, t/60000%60, t/1000%60}' )
   success "$MSG"
   note "Disk $FREE_DISKBLOCKS_START to $FREE_DISKBLOCKS_END"
}
sig_cleanup() {
    trap '' EXIT  # some shells call EXIT after the INT handler.
    false # sets $?
    this_ending
}

#################### Print run heading:

# Operating enviornment information:
HOSTNAME=$( hostname )
PUBLIC_IP=$( curl -s ifconfig.me )

if [ "$OS_TYPE" == "macOS" ]; then  # it's on a Mac:
   h2 "BASHFILE=~/.bash_profile ..."
   BASHFILE="$HOME/.bash_profile"  # on Macs
else
   h2 "BASHFILE=~/.bashrc ..."
   BASHFILE="$HOME/.bashrc"  # on Linux
fi

      note "Running $0 in $PWD"  # $0 = script being run in Present Wording Directory.
      note "$LOG_DATETIME"
      note "Bash $BASH_VERSION from $BASHFILE"
      note "OS_TYPE=$OS_TYPE using $PACKAGE_MANAGER from $DISK_PCT_FREE disk free"
      note "on hostname=$HOSTNAME at PUBLIC_IP=$PUBLIC_IP."
#   if [ -f "$OS_DETAILS" ]; then
#      note "$OS_DETAILS"
#   fi
