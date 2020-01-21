#!/usr/bin/env bash
# shellcheck disable=SC2001 # See if you can use ${variable//search/replace} instead.

# sample.sh in https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/bash/sample.sh
# coded based on bash scripting techniques described at https://wilsonmar.github.io/bash-scripting.

# This downloads and installs all the utilities, then invokes programs to prove they work
# This was run on macOS Mojave and Ubuntu 16.04.

# After you obtain a Terminal (console) in your enviornment,
# cd to folder, copy this line and paste in the terminal:
# bash -c "$(curl -fsSL  https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/bash/sample.sh)" -v -V


### STEP 1. Set display utilities:

# clear  # screen (but not history)

#set -e  # to end if 
# set -eu pipefail  # pipefail counts as a parameter
# set -x to show commands for specific issues.
# set -o nounset

# TEMPLATE: Capture starting timestamp and display no matter how it ends:
EPOCH_START="$(date -u +%s)"  # such as 1572634619
LOG_DATETIME=$(date +%Y-%m-%dT%H:%M:%S%z)-$((1 + RANDOM % 1000))


# Ensure run variables are based on arguments or defaults ..."
args_prompt() {
   echo "USAGE EXAMPLE during testing:"
   echo "./sample.sh -v -I -U -c -s -r -a -o"
   echo "USAGE EXAMPLE after testing:"
   echo "./sample.sh -v -D -M -R"
   echo "OPTIONS:"
   echo "   -h           to display this -help list"
   echo "   -v           to run -verbose (list space use and each image to console)"
   echo "   -I           -Install brew, docker, docker-compose"
   echo "   -U           -Upgrade packages"
   echo "   -c           -clone from GitHub"
   echo "   -s           Use -secrets file in your user home folder"
   echo "   -n \"John Doe\"         GitHub user -name"
   echo "   -e \"john_doe@a.com\"   GitHub user -email"
   echo "   -p \" \"    Project folder -path "
   echo "   -r           -start Docker before run"
   echo "   -a           to -actually run docker-compose"
   echo "   -o           to -open web page in default browser"
   echo "   -D           to -Delete files after run (to save disk space)"
   echo "   -M           to remove Docker iMages pulled from DockerHub"
   echo "   -R           to -Remove cloned files after run (to save disk space)"
   echo " "
 }
if [ $# -eq 0 ]; then  # display if no parameters are provided:
   args_prompt
fi
exit_abnormal() {            # Function: Exit with error.
  echo "exiting abnormally"
  #args_prompt
  exit 1
}

# Defaults (default true so flag turns it true):
   RUN_VERBOSE=false
   UPDATE_PKGS=false
   RESTART_DOCKER=false
   RUN_ACTUAL=false   # false as dry run is default.
   DOWNLOAD_INSTALL=false       # -d
   RUN_DELETE_AFTER=false       # -D
   RUN_OPEN_BROWSER=false       # -o
   CLONE_GITHUB=false           # -c
   REMOVE_GITHUB_AFTER=false    # -R
   USE_SECRETS_FILE=false       # -s
   REMOVE_DOCKER_IMAGES=false   # -M

SECRETS_FILEPATH="$HOME/.secrets.sh"  # -s
GitHub_USER_NAME=""                  # -n
GitHub_USER_EMAIL=""                 # -e
GitHub_REPO_NAME="bsawf"
PROJECT_FOLDER_PATH="$HOME/projects"

#DOCKER_DB_NANE="snakeeyes-postgres"
#DOCKER_WEB_SVC_NAME="snakeeyes_worker_1"  # from docker-compose ps  
#APPNAME="snakeeyes"

while test $# -gt 0; do
  case "$1" in
    -h)
      args_prompt  # function defined above.
      ;;
    -v)
      export RUN_VERBOSE=true
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
    -R)
      export REMOVE_GITHUB_AFTER=true
      shift
      ;;
    -M)
      export REMOVE_DOCKER_IMAGES=true
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
   printf "${dim}\n➜ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
note() { if [ "${RUN_VERBOSE}" = true ]; then
   printf "${bold}${cyan} ${reset} ${cyan}%s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
   fi
}
success() {
   printf "${green}✔ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
error() {       # &#9747;
   printf "${red}${bold}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
warning() {  # &#9758; or &#9755;
   printf "${cyan}☞ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
fatal() {   # Skull: &#9760;  # Star: &starf; &#9733; U+02606  # Toxic: &#9762;
   printf "${red}☢  %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
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
   elif [ -f "/etc/os-release" ]; then
      OS_DETAILS=$( cat "/etc/os-release" )  # ID_LIKE="rhel fedora"
      OS_TYPE="Fedora"
      PACKAGE_MANAGER="yum"
   elif [ -f "/etc/redhat-release" ]; then
      OS_DETAILS=$( cat "/etc/redhat-release" )  # ID_LIKE="rhel fedora"
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


BASH_VERSION=$( bash --version | grep bash | cut -d' ' -f4 | head -c 1 )
   if [ "${BASH_VERSION}" -lt "4" ]; then
      warning "Bash version ${BASH_VERSION} needed to calculate disk free"
      DISK_PCT_FREE="0"
      FREE_DISKBLOCKS_START="0"
   else
      DISK_PCT_FREE=$(read -d '' -ra df_arr < <(LC_ALL=C df -P /); echo "${df_arr[11]}" )
      FREE_DISKBLOCKS_START=$(read -d '' -ra df_arr < <(LC_ALL=C df -P /); echo "${df_arr[10]}" )
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
   MSG="End of script after $((EPOCH_DIFF/360)) seconds and $((FREE_DIFF*512)) bytes on disk."
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

# cd ~/environment/

      note "Running $0 in $PWD"  # $0 = script being run in Present Wording Directory.
      note "Bash $BASH_VERSION at $LOG_DATETIME"  # built-in variable.
      note "OS_TYPE=$OS_TYPE using $PACKAGE_MANAGER from $DISK_PCT_FREE disk free"
      note "on hostname=$HOSTNAME at PUBLIC_IP=$PUBLIC_IP."
#   if [ -f "$OS_DETAILS" ]; then
#      note "$OS_DETAILS"
#   fi


# Configure location to create new files:
if [ -z "$PROJECT_FOLDER_PATH" ]; then  # -p ""  override blank (the default)
   h2 "Using current folder as project folder path ..."
   pwd
else
   if [ ! -d "$PROJECT_FOLDER_PATH" ]; then  # path not available.
      h2 "Creating folder $PROJECT_FOLDER_PATH as -project folder path ..."
      mkdir -p "$PROJECT_FOLDER_PATH"
   fi
   pushd "$PROJECT_FOLDER_PATH" || return  # as suggested by SC2164
   info "Pushed into $PWD during script run ..."
fi
note "$( ls -al )"


Delete_GitHub_clone(){
   # https://www.shellcheck.net/wiki/SC2115 Use "${var:?}" to ensure this never expands to / .
   PROJECT_FOLDER_FULL_PATH="${PROJECT_FOLDER_PATH}/${GitHub_REPO_NAME}"
   if [ -d "${PROJECT_FOLDER_FULL_PATH:?}" ]; then  # path available.
      h2 "Remove project folder $PROJECT_FOLDER_FULL_PATH ..."
      ls -al "${PROJECT_FOLDER_FULL_PATH}"
      rm -rf "${PROJECT_FOLDER_FULL_PATH}"
   fi
}

if [ "${CLONE_GITHUB}" = true ]; then
   Delete_GitHub_clone    # defined above in this file.

   h2 "Downloading repo ..."
   git clone https://github.com/nickjj/build-a-saas-app-with-flask.git "$GitHub_REPO_NAME"   
   cd "$GitHub_REPO_NAME" || return 

   # curl -s -O https://raw.GitHubusercontent.com/wilsonmar/build-a-saas-app-with-flask/master/sample.sh
   # git remote add upstream https://github.com/nickjj/build-a-saas-app-with-flask
   # git pull upstream master
else
   cd "$GitHub_REPO_NAME" || return 
fi
note "$( pwd )"


### Get secrets from $HOME/.secrets.sh file:

Input_GitHub_User_Info(){
      # https://www.shellcheck.net/wiki/SC2162: read without -r will mangle backslashes.
      read -r -p "Enter your GitHub user name [John Doe]: " GitHub_USER_NAME
      GitHub_USER_NAME=${GitHub_USER_NAME:-"John Doe"}

      read -r -p "Enter your GitHub user email [john_doe@mckinsey.com]: " GitHub_USER_EMAIL
      GitHub_USER_EMAIL=${GitHub_USER_EMAIL:-"John_Doe@mckinsey.com"}
      # cp secrets.sh  "$SECRETS_FILEPATH"
}

if [ "${USE_SECRETS_FILE}" = true ]; then  # -s
   if [ ! -f "$SECRETS_FILEPATH" ]; then   # file NOT found:
      warning "File not found in $SECRETS_FILEPATH "
      Input_GitHub_User_Info  # function defined above.
   else  # found:
      h2 "Using settings in $SECRETS_FILEPATH "
      ls -al "$SECRETS_FILEPATH"
      chmod +x "$SECRETS_FILEPATH"
      source   "$SECRETS_FILEPATH"  # run file containing variable definitions.
      note "GitHub_USER_NAME=\"$GitHub_USER_NAME\" read from file $SECRETS_FILEPATH"
   fi
else
      Input_GitHub_User_Info  # function defined above.
fi  # USE_SECRETS_FILE

if [ -z "$GitHub_USER_EMAIL" ]; then 
   fatal "GitHub_USER_EMAIL is empty!"
   exit 1
else
   info "GitHub_USER_EMAIL and USER_NAME being configured ..."
   git config --global user.name  "$GitHub_USER_NAME"
   git config --global user.email "$GitHub_USER_EMAIL"
   # note "$( git config --list )"
   # note "$( git config --list --show-origin )"
fi


# Needed by snakeeyes:

   if [ ! -f ".env" ]; then
      cp .env.example  .env
   else
        note "no .env file"
   fi

   if [ ! -f "docker-compose.override.yml" ]; then
      cp docker-compose.override.example.yml  docker-compose.override.yml
   else
      warning "no .yml file"
   fi



if [ "${DOWNLOAD_INSTALL}" = true ]; then  # -D

# Install package managers:

   if [ "${PACKAGE_MANAGER}" == "brew" ]; then
      if ! command -v brew ; then
         if [ "$OS_TYPE" == "macOS" ]; then  # it's on a Mac:
            h2 "Installing brew package manager on macOS using Ruby ..."
            mkdir homebrew && curl -L https://GitHub.com/Homebrew/brew/tarball/master \
               | tar xz --strip 1 -C homebrew
         elif [ "$OS_TYPE" == "WSL" ]; then
            h2 "Installing brew package manager on WSL ..." # A fork of Homebrew known as Linuxbrew.
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
            # https://medium.com/@edwardbaeg9/using-homebrew-on-windows-10-with-windows-subsystem-for-linux-wsl-c7f1792f88b3
            # Linuxbrew installs to /home/linuxbrew/.linuxbrew/bin, so add that directory to your PATH.
            test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
            test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
            echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile
         fi
      else
         if [ "${UPDATE_PKGS}" = true ]; then
               h2 "TODO: Upgrading brew ..."
 
         fi
      fi
      note "$( brew --version )"
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
   fi # brew

# Install Docker and docker-compose:

   if [ "${PACKAGE_MANAGER}" == "brew" ]; then
      if ! command -v docker ; then
         h2 "Installing docker ..."
         brew install docker
      else
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "Upgrading docker ..."
            brew upgrade docker
         fi
      fi


      if ! command -v docker-compose ; then
         h2 "Installing docker-compose ..."
         brew install docker-compose
      else
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "Upgrading docker-compose ..."
            brew upgrade docker-compose
         fi
      fi


      if ! command -v git ; then
         h2 "Installing Git ..."
         brew install git
      else
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "Upgrading Git ..."
            brew upgrade git
         fi
      fi

   elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
      fatal "TODO apt-get install docker"
      apt-get install docker
      apt-get install docker-compose
   elif [ "${PACKAGE_MANAGER}" == "yum" ]; then
      fatal "TODO yum install docker"
      yum install docker
      yum install docker-compose
   fi # brew

fi  # if [ "${DOWNLOAD_INSTALL}" = true ]; then  # -D

      note "$( docker --version )"
         # Docker version 19.03.5, build 633a0ea
      note "$( docker-compose --version )"
         # docker-compose version 1.24.1, build 4667896b
      note "$( git --version )"  # git version 2.20.1 (Apple Git-117)


## Restart Docker DAEMON

Start_Docker(){
   if [ "$OS_TYPE" == "macOS" ]; then  # it's on a Mac:
      h2 "Opening Docker daemon on macOS ..."
      open --background -a Docker   # open "/Applications/Docker.app"
      # /Applications/Docker.app/Contents/MacOS/Docker
   else
      h2 "Starting Docker daemon on Linux ..."
      sudo systemctl start docker
      sudo service docker start
   fi
      sleep 5  # it takes at least that
      # Wait until Docker daemon is running and has completed initialisation
      while (! docker stats --no-stream ); do
         # Docker takes a few seconds to initialize
         note "Waiting for Docker to launch..."
         sleep 3  # seconds
      done
         # Docker is running when it can list all containers:
         # CONTAINER ID        NAME                  CPU %               MEM USAGE / LIMIT     MEM %               NET I/O             BLOCK I/O           PIDS
         # d6033f8e731a        snakeeyes_web_1       0.32%               40.18MiB / 1.952GiB   2.01%               7.24kB / 43.3kB     1.12MB / 0B         3
         # b8c2f5956e75        snakeeyes_worker_1    0.08%               138.8MiB / 1.952GiB   6.95%               50.9MB / 53.4MB     4.1kB / 0B          8
         # c881a6472995        snakeeyes_webpack_1   4.05%               133.5MiB / 1.952GiB   6.68%               4.63kB / 0B         127kB / 0B          23
         # e28b839510b2        snakeeyes_redis_1     0.25%               1.723MiB / 1.952GiB   0.09%               53.4MB / 50.9MB     49.2kB / 94.2kB     4
}
# From https://gist.github.com/peterver/ca2d60abc015d334e1054302265b27d9
# https://medium.com/@valkyrie_be/quicktip-a-universal-way-to-check-if-docker-is-running-ffa6567f8426
rep=$(curl -s --unix-socket /var/run/docker.sock http://ping > /dev/null)
status=$?
if [ "$status" == "7" ]; then   # Not Docker connected:
#if (! pgrep -f docker ); then   # No docker process IDs found:
   Start_Docker   # function defined in this file above.
else   # Docker processes found running:
   if [ "${RESTART_DOCKER}" = true ]; then
      if [ "$OS_TYPE" == "macOS" ]; then  # it's on a Mac:
         h2 "Stopping Docker on macOS ..."
         osascript -e 'quit app "Docker"'
      else
         h2 "Stopping Docker on Linux ..."
         sudo systemctl stop docker
         sudo service docker stop
      fi
   fi
   Start_Docker   # function defined in this file above.
fi


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
      sleep 3
      open http://localhost:8000/
   fi
fi
      curl -s -I -X POST http://localhost:8000/ 
      curl -s       POST http://localhost:8000/ | head -n 10  # first 10 lines


# TODO: Run tests



if [ "$RUN_DELETE_AFTER" = true ]; then  # -D
      # https://www.thegeekdiary.com/how-to-list-start-stop-delete-docker-containers/
   h2 "Deleting docker-compose active containers ..."
   CONTAINERS_RUNNING="$( docker ps -a -q )"
#   note "Active containers: $CONTAINERS_RUNNING"

   note "Stopping containers:"
   docker stop "$( docker ps -a -q )"

   note "Removing containers:"
   docker rm -v "$( docker ps -a -q )"
fi


if [ "$REMOVE_DOCKER_IMAGES" = true ]; then  # -M
   DOCKER_IMAGES="$( docker images -a -q )"
   if [ -n "$DOCKER_IMAGES" ]; then  # variable is NOT empty
      h2 "Removing all Docker images ..."
      docker rmi "$( docker images -a -q )"
   fi
fi
note "$( docker images -a )"


if [ "$REMOVE_GITHUB_AFTER" = true ]; then  # -R
   Delete_GitHub_clone    # defined above in this file.
fi

# END

