#!/usr/bin/env bash
# shellcheck disable=SC2001 # See if you can use ${variable//search/replace} instead.

# sample.sh in https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/bash/sample.sh
# coded based on bash scripting techniques described at https://wilsonmar.github.io/bash-scripting.

# This downloads and installs all the utilities, then invokes programs to prove they work
# This was tested on macOS Mojave.

# After you obtain a Terminal (console) in your enviornment,
# cd to folder, copy this line and paste in the terminal:
# bash -c "$(curl -fsSL  https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/bash/sample.sh)" -v -V


### STEP 1. Set display utilities:

clear  # screen (but not history)

set -e  # to end if 
# set -eu pipefail  # pipefail counts as a parameter
# set -x to show commands for specific issues.
# set -o nounset

# TEMPLATE: Capture starting timestamp and display no matter how it ends:
EPOCH_START="$(date -u +%s)"  # such as 1572634619
LOG_DATETIME=$(date +%Y-%m-%dT%H:%M:%S%z)-$((1 + RANDOM % 1000))
FREE_DISKBLOCKS_START="$( df -m . | cut -d' ' -f 6 )"   # e.g. 254781 MB Used

trap this_ending EXIT
trap this_ending INT QUIT TERM
this_ending() {
   EPOCH_END=$(date -u +%s);
   DIFF=$((EPOCH_END-EPOCH_START))
   FREE_DISKBLOCKS_END="$( df -m . | cut -d' ' -f 6 )"   # e.g. 254781 MB Used
   DIFF=$(((FREE_DISKBLOCKS_START-FREE_DISKBLOCKS_END)))

   MSG="End of script after $((DIFF/360)) minutes and $DIFF bytes disk space consumed."
   # echo 'Elapsed HH:MM:SS: ' $( awk -v t=$beg-seconds 'BEGIN{t=int(t*1000); printf "%d:%02d:%02d\n", t/3600000, t/60000%60, t/1000%60}' )
   echo "$MSG"
   echo "Disk $FREE_DISKBLOCKS_START to $FREE_DISKBLOCKS_END"
}
sig_cleanup() {
    trap '' EXIT  # some shells call EXIT after the INT handler.
    false # sets $?
    this_ending
}

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
  printf "${dim}\n➜ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
RUN_VERBOSE=true
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

# Check what operating system is in use:
   OS_TYPE="$( uname )"
   OS_DETAILS=""  # default blank.
if [ "$(uname)" == "Darwin" ]; then  # it's on a Mac:
      OS_TYPE="macOS"
      PACKAGE_MANAGER="brew"
elif [ "$(uname)" == "Linux" ]; then  # it's on a Mac:
   if command -v lsb_release ; then
      lsb_release -a
      OS_TYPE="Ubuntu"  # for apt-get
      PACKAGE_MANAGER="apt-get"
   elif [ -f "/etc/os-release" ]; then
      OS_DETAILS=$( cat "/etc/os-release" )  # ID_LIKE="rhel fedora"
      OS_TYPE="Fedora"  # for yum 
      PACKAGE_MANAGER="yum"
   elif [ -f "/etc/redhat-release" ]; then
      OS_DETAILS=$( cat "/etc/redhat-release" )  # ID_LIKE="rhel fedora"
      OS_TYPE="RedHat"  # for yum 
      PACKAGE_MANAGER="yum"
   elif [ -f "/etc/centos-release" ]; then
      OS_TYPE="CentOS"  # for yum
      PACKAGE_MANAGER="yum"
   else
      error "Linux distribution not anticipated. Please update script. Aborting."
      exit 0
   fi
else 
   error "Operating system not anticipated. Please update script. Aborting."
   exit 0
fi


#################### Print run heading:

# Operating enviornment information:
HOSTNAME=$( hostname )
PUBLIC_IP=$( curl -s ifconfig.me )

# cd ~/environment/

      note "Running $0 in $PWD"  # $0 = script being run in Present Wording Directory.
      note "Bash $BASH_VERSION at $LOG_DATETIME"  # built-in variable.
      note "OS_TYPE=$OS_TYPE on hostname=$HOSTNAME at PUBLIC_IP=$PUBLIC_IP."
   if [ -f "$OS_DETAILS" ]; then
      note "$OS_DETAILS"
   fi


# Ensure run variables are based on arguments or defaults ..."
args_prompt() {
   echo "USAGE EXAMPLE during testing:"
   echo "   $0 -v -U -D -a -o -d"
   echo "OPTIONS:"
   echo "   -v           to run verbose (list space use and each image to console)"
   echo "   -D           Download installers"
   echo "   -U           Upgrade packages"
   echo "   -n \"John Doe\"      GitHub user name"
   echo "   -e \"john_doe@a.com\"      GitHub user email"
   echo "   -p \"?/?\"      Project folder path"
   echo "   -R           reboot Docker before run"
   echo "   -a           to actually run docker-compose"
   echo "   -o           to open web page in default browser"
   echo "   -d           to delete files after run (to save disk space)"
 }
if [ $# -eq 0 ]; then  # display if no paramters are provided:
   args_prompt
fi
exit_abnormal() {                              # Function: Exit with error.
  args_prompt
  exit 1
}

# Defaults (default true so flag turns it true):
   UPDATE_PKGS=false
   RESTART_DOCKER=false
   RUN_ACTUAL=false  # false as dry run is default.
   DOWNLOAD_INSTALL=false     # -d
   RUN_DELETE_AFTER=false     # -D
   RUN_OPEN_BROWSER=false     # -o

SECRETS_FILEPATH="$HOME/secrets.sh"  # -s
GitHub_USER_NAME=""                  # -n
GitHub_USER_EMAIL=""                 # -e
GitHub_REPO_NAME="bsawf"
PROJECT_FOLDER_PATH="$HOME/projects"

#DOCKER_DB_NANE="snakeeyes-postgres"
#DOCKER_WEB_SVC_NAME="snakeeyes_worker_1"  # from docker-compose ps  
#APPNAME="snakeeyes"

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      args_prompt
      exit 0
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
    -s*)
      shift
             SECRETS_FILEPATH=$( echo "$1" | sed -e 's/^[^=]*=//g' )
      export SECRETS_FILEPATH
      shift
      ;;
    -U)
      export UPDATE_PKGS=true
      shift
      ;;
    -R)
      export RESTART_DOCKER=true
      shift
      ;;
    -v)
      export RUN_VERBOSE=true
      shift
      ;;
    -d)
      export DOWNLOAD_INSTALL=true
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
    *)
      error "Parameter \"$1\" not recognized. Aborting."
      exit 0
      break
      ;;
  esac
done

exit


# Configure location to create new files:
if [ ! -d "$HOME/projects" ]; then
   h2 "Make folder ..."
   mkdir -p "$HOME/projects"
fi
   pushd "$HOME/projects/"
   info "Now at $PWD during script run ..."
   note "$( ls -al )"



if [ "${DOWNLOAD_INSTALL}" = true ]; then  # -d
   if [ -d "$GitHub_REPO_NAME" ]; then 
      rm -rf "$HOME/projects/$GitHub_REPO_NAME"
   fi

   h2 "Downloading repo ..."
   git clone https://github.com/nickjj/build-a-saas-app-with-flask.git "$GitHub_REPO_NAME"   
   cd "$GitHub_REPO_NAME"

   # curl -s -O https://raw.GitHubusercontent.com/wilsonmar/build-a-saas-app-with-flask/master/sample.sh
   # git remote add upstream https://github.com/nickjj/build-a-saas-app-with-flask
   # git pull upstream master
else
   cd "$GitHub_REPO_NAME"  
fi


   if [ ! -f ".env" ]; then
      cp .env.example .env
   else
        note "no .env file"
   fi

   if [ ! -f "docker-compose.override.yml" ]; then
      cp docker-compose.override.example.yml docker-compose.override.yml
   else
        note "no .yml file"
   fi



## Setup env

   if [ "${PACKAGE_MANAGER}" == "brew" ]; then
      if ! command -v brew ; then
         h2 "Installing brew package manager using Ruby ..."
         mkdir homebrew && curl -L https://GitLab.com/Homebrew/brew/tarball/master \
            | tar xz --strip 1 -C homebrew
      else
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "Upgrading brew ..."
         fi
      fi
      note "$( brew --version)"
         # Homebrew 2.2.2
         # Homebrew/homebrew-core (git revision e103; last commit 2020-01-07)
         # Homebrew/homebrew-cask (git revision bbf0e; last commit 2020-01-07)
   elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then  # (Advanced Packaging Tool) for Debian/Ubuntu
      if ! command -v apt-get ; then
         h2 "Installing apt-get package manager ..."
         wget http://security.ubuntu.com/ubuntu/pool/main/a/apt/apt_1.0.1ubuntu2.17_amd64.deb -O apt.deb
         sudo dpkg -i apt.deb
         # Alternative:
         # pkexec dpkg -i apt.deb
      else
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "Upgrading apt-get ..."
            # https://askubuntu.com/questions/194651/why-use-apt-get-upgrade-instead-of-apt-get-dist-upgrade
            sudo apt-get update && time sudo apt-get dist-upgrade
         fi
      fi
      note "$( apt-get --version )"

   elif [ "${PACKAGE_MANAGER}" == "yum" ]; then  #  (Yellow dog Updater Modified) for Red Hat, CentOS
      if ! command -v yum ; then
         h2 "Installing yum rpm package manager ..."
         # https://www.unix.com/man-page/linux/8/rpm/
         wget https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
         rpm -ivh yum-3.4.3-154.el7.centos.noarch.rpm
      else
         if [ "${UPDATE_PKGS}" = true ]; then
            #rpm -ivh telnet-0.17-60.el7.x86_64.rpm
            # https://unix.stackexchange.com/questions/109424/how-to-reinstall-yum
            rpm -V yum
            # https://www.cyberciti.biz/faq/rhel-centos-fedora-linux-yum-command-howto/
         fi
      fi
   #  Suse Linux "${PACKAGE_MANAGER}" == "zypper" ?
   fi


      if ! command -v docker ; then
         h2 "Installing docker ..."
         brew install docker
      else
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "Upgrading docker ..."
            brew upgrade docker
         fi
      fi
      note "$( docker --version )"
         # Docker version 19.03.5, build 633a0ea


      if ! command -v docker-compose ; then
         h2 "Installing docker-compose ..."
         brew install docker-compose
      else
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "Upgrading docker-compose ..."
            brew upgrade docker-compose
         fi
      fi
      note "$( docker-compose --version )"
         # docker-compose version 1.24.1, build 4667896b


## TODO: Restart Docker DAEMON


#   if [ -z `docker ps -q --no-trunc | grep $(docker-compose ps -q "$DOCKER_WEB_SVC_NAME")` ]; then
      # --no-trunc flag because docker ps shows short version of IDs by default.

#.   note "If $DOCKER_WEB_SVC_NAME is not running, so run it..."

if [ "${RUN_ACTUAL}" = true ]; then

      # https://docs.docker.com/compose/reference/up/
      docker-compose up --detach --build
         # --build specifies rebuild of pip install image for changes in requirements.txt
         # NOTE: detach with ^P^Q.
         # Creating network "snakeeyes_default" with the default driver
         # Creating volume "snakeeyes_redis" with default driver
         # Status: Downloaded newer image for node:12.14.0-buster-slim

      # worker_1   | [2020-01-17 04:59:42,036: INFO/Beat] beat: Starting...
fi

        h2 "docker container ls ..."
      docker container ls
         # CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS                    PORTS                    NAMES
         # 3ee3e7ef6d75        snakeeyes_web        "/app/docker-entrypo…"   35 minutes ago      Up 35 minutes (healthy)   0.0.0.0:8000->8000/tcp   snakeeyes_web_1
         # fb64e7c95865        snakeeyes_worker     "/app/docker-entrypo…"   35 minutes ago      Up 35 minutes             8000/tcp                 snakeeyes_worker_1
         # bc68e7cb0f41        snakeeyes_webpack    "docker-entrypoint.s…"   About an hour ago   Up 35 minutes                                      snakeeyes_webpack_1
         # 52df7a11b666        redis:5.0.7-buster   "docker-entrypoint.s…"   About an hour ago   Up 35 minutes             6379/tcp                 snakeeyes_redis_1
         # 7b8aba1d860a        postgres             "docker-entrypoint.s…"   7 days ago          Up 7 days                 0.0.0.0:5432->5432/tcp   snoodle-postgres

if [ "$RUN_OPEN_BROWSER" = true ]; then  # -o
   if [ "$OS_TYPE" == "macOS" ]; then  # it's on a Mac:
      open http://localhost:8000/
   fi
fi


# TODO: Run tests


if [ "$RUN_DELETE_AFTER" = true ]; then  # -D
   docker-compose rm -f
fi

