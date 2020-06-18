#!/usr/bin/env bash
# shellcheck disable=SC2001 # See if you can use ${variable//search/replace} instead.
# shellcheck disable=SC1090 # Can't follow non-constant source. Use a directive to specify location.

# sample.sh in https://github.com/wilsonmar/DevSecOps/blob/master/bash/sample.sh
# coded based on bash scripting techniques described at https://wilsonmar.github.io/bash-scripting.

# This downloads and installs all the utilities, then invokes programs to prove they work
# This was run on macOS Mojave and Ubuntu 16.04.

# After you obtain a Terminal (console) in your enviornment,
# cd to folder, copy this line and paste in the terminal:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/bash/sample.sh)" -v -i

THIS_PROGRAM="$0"
SCRIPT_VERSION="v0.71"
# clear  # screen (but not history)

# Capture starting timestamp and display no matter how it ends:
EPOCH_START="$( date -u +%s )"  # such as 1572634619
LOG_DATETIME=$( date +%Y-%m-%dT%H:%M:%S%z)-$((1 + RANDOM % 1000))
echo "=========================== $LOG_DATETIME $THIS_PROGRAM $SCRIPT_VERSION"


# Ensure run variables are based on arguments or defaults ..."
args_prompt() {
   echo "OPTIONS:"
   echo "   -E           to set -e to NOT stop on error"
   echo "   -v           to run -verbose (list space use and each image to console)"
   echo "   -q           -quiet headings for each step"
   echo "   -x           to set -x to trace command lines"
#   echo "   -x           to set sudoers -e to stop on error"
   echo " "
   echo "   -I           -Install jq, brew, docker, docker-compose, etc."
   echo "   -U           -Upgrade installed packages"
   echo " "
   echo "   -s           -secrets retrieve"
   echo "   -S \"~/.alt.secrets.sh\"  -Secrets full file path"
   echo "   -H           install/use -Hashicorp Vault secret manager"
   echo "   -m           Setup Vault SSH CA cert"
   echo " "
   echo "   -L           use CircleCI"
   echo "   -aws         -AWS cloud"
   echo "   -eks         -eks (Elastic Kubernetes Service) in AWS cloud"
   echo "   -g \"abcdef...89\" -gcloud API credentials for calls"
   echo "   -p \"cp100\"   -project in cloud"
   echo " "
   echo "   -d           -delete GitHub and pyenv from previous run"
   echo "   -c           -clone from GitHub"
   echo "   -N           -Name of GitHub Repo folder"
   echo "   -n \"John Doe\"            GitHub user -name"
   echo "   -e \"john_doe@gmail.com\"  GitHub user -email"
   echo " "
   echo "   -k8s         -k8s (Kubernetes) minikube"
   echo "   -k           -k install and use Docker"
   echo "   -b           -build Docker image"
   echo "   -w           -write image to DockerHub"
   echo "   -r           -restart Docker before run"
   echo "   -V           to run within VirtualEnv (pipenv is default)"
   echo " "
   echo "   -T           run -Tensorflow"
   echo "   -A           run with Python -Anaconda "
   echo "   -py          run with Pyenv"
   echo "   -G           run python in -GitHub "
   echo "   -y            install Python Flask"
   echo "   -i           -install Ruby and Refinery"
   echo "   -j            install -JavaScript (NodeJs) app with MongoDB"
   echo " "
   echo "   -F \"abc\"     -Folder inside repo"
   echo "   -f \"a9y.py\"  -file (program) to run"
   echo "   -P \"-v -x\"   -Parameters controlling program called"
   echo "   -a           -actually run server (not dry run)"
   echo "   -t           setup -test server to run tests"
   echo "   -o           -open/view app or web page (in default browser)"
   echo " "
   echo "   -K           stop processes at end of run (to save CPU)"
   echo "   -D           -Delete files after run (to save disk space)"
   echo "   -C           remove -Cloned files after run (to save disk space)"
   echo "   -M           remove Docker iMages pulled from DockerHub"
   echo "USAGE EXAMPLE during testing:"
   echo "./sample.sh -v -O   -r -k -K -D  # eggplant use docker-compose of selenium-hub images"
   echo "./sample.sh -v -S \"\$HOME/.mck-secrets.sh\" -eks -D "
   echo "./sample.sh -v -S \"\$HOME/.mck-secrets.sh\" -H -m -t    # Use SSH-CA certs with -H Hashicorp Vault -test actual server"
   echo "./sample.sh -v -g \"abcdef...89\" -p \"cp100-1094\"  # Google API call"
   echo "./sample.sh -v -n -a  # NodeJs app with MongoDB"
   echo "./sample.sh -v -i -o  # Ruby app"   
   echo "./sample.sh -v -I -U -c -s -y -r -a -AWS   # Python Flask web app in Docker"
   echo "./sample.sh -v -I -U    -s -H    -t        # Initiate Vault test server"
   echo "./sample.sh -v          -s -H              #      Run Vault test program"
   echo "./sample.sh -q          -s -H    -a        # Initiate Vault prod server"
   echo "./sample.sh -v -I -U -c    -H -G -N \"python-samples\" -f \"a9y-sample.py\" -P \"-v\" -t -AWS -C  # Python sample app using Vault"
   echo "./sample.sh -v -V -c -T -F \"section_2\" -f \"2-1.ipynb\" -K  # Jupyter anaconda Tensorflow in Venv"
   echo "./sample.sh -v -V -c -L -s    # Use CircLeci based on secrets"
   echo "./sample.sh -v -D -M -C"
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
   RUN_ACTUAL=false             # -a  (dry run is default)
   SET_EXIT=true                # -E
   SET_TRACE=false              # -x
   RUN_VERBOSE=false            # -v
   RUN_TESTS=false              # -t
   RUN_VIRTUALENV=false         # -V
   RUN_ANACONDA=false           # -A
   RUN_PYTHON=false             # -G
   RUN_PARMS=""                 # -P
   USE_CIRCLECI=false           # -L
   USE_DOCKER=false             # -k
   INSTALL_AWS_CLIENT=false     #
   USE_YUBIKEY=false            # -Y

   USE_AWS_CLOUD=false          # -aws
   RUN_EKS=false                # -eks
   # From AWS Management Console https://console.aws.amazon.com/iam/
      AWS_OUTPUT_FORMAT="json"  # asked by aws configure CLI.
   # From secrets file:
      AWS_ACCESS_KEY_ID=""
      AWS_SECRET_ACCESS_KEY=""
      AWS_USER_ARN=""
      AWS_MFA_ARN=""
      AWS_DEFAULT_REGION="us-east-2"
      EKS_CLUSTER_NAME="sample-k8s"
      EKS_KEY_FILE_PREFIX="eksctl-1"
      EKS_NODES="2"
      EKS_NODE_TYPE="m5.large"
   EKS_CLUSTER_FILE=""   # cluster.yaml instead
   EKS_CRED_IS_LOCAL=true
   USE_K8S=false                # -k8s
   USE_AZURE_CLOUD=false        # -z
   USE_GOOGLE_CLOUD=false       # -g
       GOOGLE_API_KEY=""  # manually copied from APIs & services > Credentials
   PROJECT_NAME=""              # -p                 
   USE_VAULT=false              # -H
   RUBY_INSTALL=false           # -i
   MOVE_SECURELY=false          # -m
   NODE_INSTALL=false           # -n
      MONGO_DB_NAME=""
   USE_SECRETS_FILE=false       # -s
   SECRETS_FILEPATH="$HOME/.secrets.sh"  # -S
   SECRETS_FILE="variables.env.sample"
   MY_FOLDER=""
   MY_FILE=""
     #MY_FILE="2-3.ipynb"
   RUN_EGGPLANT=false           # -eggplant
   RUN_QUIET=false              # -q
   UPDATE_PKGS=false            # -U

   RESTART_DOCKER=false         # -r
   BUILD_DOCKER_IMAGE=false     # -b
   WRITE_TO_DOCKERHUB=false     # -w
   USE_PYENV=false              # -py
   DOWNLOAD_INSTALL=false       # -I
   DELETE_CONTAINER_AFTER=false # -D
   RUN_TENSORFLOW=false         # -T
   OPEN_APP=false               # -o
   APP1_PORT="8000"

   CLONE_GITHUB=false           # -c

   REMOVE_DOCKER_IMAGES=false   # -M
   REMOVE_GITHUB_AFTER=false    # -R
   KILL_PROCESSES=false         # -K

PROJECT_FOLDER_PATH="$HOME/projects"  # -P
export GitHub_REPO_NAME=""
export GitHub_USER_NAME="WilsonMar"             # -n
export GitHub_USER_EMAIL="wilson_mar@gmail.com"  # -e

while test $# -gt 0; do
  case "$1" in
    -a)
      export RUN_ACTUAL=true
      shift
      ;;
    -A)
      export RUN_ANACONDA=true
      shift
      ;;
    -aws)
      export USE_AWS_CLOUD=true
      shift
      ;;
    -b)
      export BUILD_DOCKER_IMAGE=true
      shift
      ;;
    -c)
      export CLONE_GITHUB=true
      shift
      ;;
    -C)
      export REMOVE_GITHUB_AFTER=true
      shift
      ;;
    -d)
      export REMOVE_GITHUB_BEFORE=true
      shift
      ;;
    -D)
      export DELETE_CONTAINER_AFTER=true
      shift
      ;;
    -eks)
      # export INSTALL_AWS_CLIENT=true
      export USE_AWS_CLOUD=true
      export RUN_EKS=true
      shift
      ;;
    -e*)
      shift
             GitHub_USER_EMAIL=$( echo "$1" | sed -e 's/^[^=]*=//g' )
      export GitHub_USER_EMAIL
      shift
      ;;
    -E)
      export SET_EXIT=false
      shift
      ;;
    -f*)
      shift
      export MY_FILE=$( echo "$1" | sed -e 's/^[^=]*=//g' )
      shift
      ;;
    -F*)
      shift
      export MY_FOLDER=$( echo "$1" | sed -e 's/^[^=]*=//g' )
      shift
      ;;
    -g*)
      shift
      export USE_GOOGLE_CLOUD=true
             GOOGLE_API_KEY=$( echo "$1" | sed -e 's/^[^=]*=//g' )
      export GOOGLE_API_KEY
      shift
      ;;
    -G)
      export RUN_PYTHON=true
      GitHub_REPO_URL="https://github.com/wilsonmar/python-samples.git"
      GitHub_REPO_NAME="python-samples"
      shift
      ;;
    -H)
      export USE_VAULT=true
      shift
      ;;
    -i)
      export RUBY_INSTALL=true
      GitHub_REPO_URL="https://github.com/nickjj/build-a-saas-app-with-flask.git"
      GitHub_REPO_NAME="bsawf"
      #DOCKER_DB_NANE="snakeeyes-postgres"
      #DOCKER_WEB_SVC_NAME="snakeeyes_worker_1"  # from docker-compose ps  
      APPNAME="snakeeyes"
      shift
      ;;
    -I)
      export DOWNLOAD_INSTALL=true
      shift
      ;;
    -j)
      export NODE_INSTALL=true
      GitHub_REPO_URL="https://github.com/wesbos/Learn-Node.git"
      GitHub_REPO_NAME="delicious"
      APPNAME="delicious"
      MONGO_DB_NAME="delicious"
      shift
      ;;
    -k)
      export USE_DOCKER=true
      shift
      ;;
    -k8s)
      export USE_K8S=true
      shift
      ;;
    -K)
      export KILL_PROCESSES=true
      shift
      ;;
    -L)
      export USE_CIRCLECI=true
      #GitHub_REPO_URL="https://github.com/wilsonmar/circleci_demo.git"
      GitHub_REPO_URL="https://github.com/fedekau/terraform-with-circleci-example"
      GitHub_REPO_NAME="circleci_demo"
      shift
      ;;
    -m)
      export MOVE_SECURELY=true
      shift
      ;;
    -M)
      export REMOVE_DOCKER_IMAGES=true
      shift
      ;;
    -n*)
      shift
      # shellcheck disable=SC2034 # ... appears unused. Verify use (or export if used externally).
             GitHub_USER_NAME=$( echo "$1" | sed -e 's/^[^=]*=//g' )
      export GitHub_USER_NAME
      shift
      ;;
    -N*)
      shift
             GitHub_REPO_NAME=$( echo "$1" | sed -e 's/^[^=]*=//g' )
      export GitHub_REPO_NAME
      shift
      ;;
    -o)
      export OPEN_APP=true
      shift
      ;;
    -O)
      export RUN_EGGPLANT=true
      export GitHub_REPO_URL="https://github.com/SeleniumHQ/docker-selenium.git"
      export GitHub_REPO_NAME="eggplant-demo"
      shift
      ;;
    -py)
      export USE_PYENV=true
      shift
      ;;
    -p*)
      shift
             PROJECT_NAME=$( echo "$1" | sed -e 's/^[^=]*=//g' )
      export PROJECT_NAME
      shift
      ;;
    -P*)
      shift
             RUN_PARMS=$( echo "$1" | sed -e 's/^[^=]*=//g' )
      export RUN_PARMS
      shift
      ;;
    -q)
      export RUN_QUIET=true
      shift
      ;;
    -r)
      export RESTART_DOCKER=true
      shift
      ;;
    -s)
      export USE_SECRETS_FILE=true
      shift
      ;;
    -S*)
      export USE_SECRETS_FILE=true
      shift
             SECRETS_FILEPATH=$( echo "$1" | sed -e 's/^[^=]*=//g' )
      export SECRETS_FILEPATH
      shift
      ;;
    -t)
      export RUN_TESTS=true
      shift
      ;;
    -T)
      export RUN_TENSORFLOW=true
      export RUN_ANACONDA=true
      shift
      ;;
    -U)
      export UPDATE_PKGS=true
      shift
      ;;
    -v)
      export RUN_VERBOSE=true
      shift
      ;;
    -V)
      export RUN_VIRTUALENV=true
      GitHub_REPO_URL="https://github.com/PacktPublishing/Hands-On-Machine-Learning-with-Scikit-Learn-and-TensorFlow-2.0.git"
      export GitHub_REPO_NAME="scikit"
      export APPNAME="scikit"
      #MY_FOLDER="section_2" # or ="section_3"
      shift
      ;;
    -x)
      export SET_TRACE=true
      shift
      ;;
    -w)
      export WRITE_TO_DOCKERHUB=true
      shift
      ;;
    -y)
      GitHub_REPO_URL="https://github.com/nickjj/build-a-saas-app-with-flask.git"
      export GitHub_REPO_NAME="rockstar"
      export APPNAME="rockstar"
      shift
      ;;
    -Y)
      export USE_YUBIKEY=true
      shift
      ;;
    -z)
      export USE_AZURE_CLOUD=true
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

h2() { if [ "${RUN_QUIET}" = false ]; then    # heading
   printf "\n${bold}\e[33m\u2665 %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
   fi
}
info() {   # output on every run
   printf "${dim}\n➜ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
note() { if [ "${RUN_VERBOSE}" = true ]; then
   printf "\n${bold}${cyan} ${reset} ${cyan}%s${reset}" "$(echo "$@" | sed '/./,$!d')"
   printf "\n"
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
      export OS_TYPE="macOS"
      export PACKAGE_MANAGER="brew"
elif [ "$(uname)" == "Linux" ]; then  # it's on a Mac:
   if command -v lsb_release ; then
      lsb_release -a
      export OS_TYPE="Ubuntu"
      # TODO: OS_TYPE="WSL" ???
      export PACKAGE_MANAGER="apt-get"

      # TODO: sudo dnf install pipenv  # for Fedora 28

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
      export OS_TYPE="Fedora"
      export PACKAGE_MANAGER="yum"
   elif [ -f "/etc/redhat-release" ]; then
      export OS_DETAILS=$( cat "/etc/redhat-release" )
      export OS_TYPE="RedHat"
      export PACKAGE_MANAGER="yum"
   elif [ -f "/etc/centos-release" ]; then
      export OS_TYPE="CentOS"
      export PACKAGE_MANAGER="yum"
   else
      error "Linux distribution not anticipated. Please update script. Aborting."
      exit 0
   fi
else 
   error "Operating system not anticipated. Please update script. Aborting."
   exit 0
fi
# note "OS_DETAILS=$OS_DETAILS"


# bash function to kill process by name:
ps_kill(){  # $1=process name
      PSID=$(ps aux | grep $1 | awk '{print $2}')
      if [ -z "$PSID" ]; then
         h2 "Kill $1 PSID= $PSID ..."
         kill 2 "$PSID"
         sleep 2
      fi
}


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
   fi

trap this_ending EXIT
trap this_ending INT QUIT TERM
this_ending() {
   EPOCH_END=$(date -u +%s);
   EPOCH_DIFF=$((EPOCH_END-EPOCH_START))
   # Using BASH_VERSION identified above:
   if [ "${BASH_VERSION}" -lt "4" ]; then
      FREE_DISKBLOCKS_END="0"
   else
      FREE_DISKBLOCKS_END=$(read -d '' -ra df_arr < <(LC_ALL=C df -P /); echo "${df_arr[10]}" )
   fi
   FREE_DIFF=$(((FREE_DISKBLOCKS_END-FREE_DISKBLOCKS_START)))
   MSG="End of script $SCRIPT_VERSION after $((EPOCH_DIFF/360)) seconds and $((FREE_DIFF*512)) bytes on disk."
   # echo 'Elapsed HH:MM:SS: ' $( awk -v t=$beg-seconds 'BEGIN{t=int(t*1000); printf "%d:%02d:%02d\n", t/3600000, t/60000%60, t/1000%60}' )
   success "$MSG"
   # note "Disk $FREE_DISKBLOCKS_START to $FREE_DISKBLOCKS_END"
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
   note "BASHFILE=~/.bash_profile ..."
   BASHFILE="$HOME/.bash_profile"  # on Macs
else
   note "BASHFILE=~/.bashrc ..."
   BASHFILE="$HOME/.bashrc"  # on Linux
fi

      note "Running $0 in $PWD"  # $0 = script being run in Present Wording Directory.
      note "Start time $LOG_DATETIME"
      note "Bash $BASH_VERSION from $BASHFILE"
      note "OS_TYPE=$OS_TYPE using $PACKAGE_MANAGER from $DISK_PCT_FREE disk free"
      note "on hostname=$HOSTNAME at PUBLIC_IP=$PUBLIC_IP."
      note " "
# print all command arguments submitted:
#while (( "$#" )); do 
#  echo $1 
#  shift 
#done 


IFS=$'\n\t'  #  Internal Field Separator for word splitting is line or tab, not spaces.

# Configure location to create new files:
if [ -z "$PROJECT_FOLDER_PATH" ]; then  # -p ""  override blank (the default)
   h2 "Using current folder as project folder path ..."
   pwd
else
   if [ ! -d "$PROJECT_FOLDER_PATH" ]; then  # path not available.
      note "Creating folder $PROJECT_FOLDER_PATH as -project folder path ..."
      mkdir -p "$PROJECT_FOLDER_PATH"
   fi
   pushd "$PROJECT_FOLDER_PATH" || return # as suggested by SC2164
   note "Pushed into path $PWD during script run ..."
fi
# note "$( ls )"

EXIT_CODE=0
if [ "${SET_EXIT}" = true ]; then  # don't
   h2 "Set -e (no -E parameter  )..."
   set -e  # exits script when a command fails
   # set -eu pipefail  # pipefail counts as a parameter
else
   warning "Don't set -e (-E parameter)..."
fi
if [ "${SET_XTRACE}" = true ]; then
   h2 "Set -x ..."
   set -x  # (-o xtrace) to show commands for specific issues.
fi
# set -o nounset

### Get secrets from $HOME/.secrets.sh file:
Input_GitHub_User_Info(){
      # https://www.shellcheck.net/wiki/SC2162: read without -r will mangle backslashes.
      read -r -p "Enter your GitHub user name [John Doe]: " GitHub_USER_NAME
      GitHub_USER_NAME=${GitHub_USER_NAME:-"John Doe"}
      GitHub_ACCOUNT=${GitHub_ACCOUNT:-"john-doe"}

      read -r -p "Enter your GitHub user email [john_doe@gmail.com]: " GitHub_USER_EMAIL
      GitHub_USER_EMAIL=${GitHub_USER_EMAIL:-"johb_doe@gmail.com"}
}
# TODO: https://www.passwordstore.org using brew install pass


if [ "${USE_SECRETS_FILE}" = false ]; then  # -s
   warning "Using default values hard-coded in this bash script ..."
   # Input_GitHub_User_Info  # function defined above.
   # flag not to use file, then manually input:

   # See https://pipenv-fork.readthedocs.io/en/latest/advanced.html#automatic-loading-of-env
   # PIPENV_DOTENV_LOCATION=/path/to/.env or =1 to not load.
else
   if [ ! -f "$SECRETS_FILEPATH" ]; then   # file NOT found, then copy from github:
      fatal "File not found in -secrets file $SECRETS_FILEPATH."
      code "${SECRETS_FILEPATH}"
      exit 9

      warning "Downloading file .secrets.sample.sh ... "
      #curl -s -O https://raw.GitHubusercontent.com/wilsonmar/DevSecOps/master/secrets.sample.sh
      #warning "Copying secrets.sample.sh downloaded to \$HOME/.secrets.sh ... "
      #cp secrets.sample.sh  .secrets.sh
      #fatal "Please edit file \$HOME/.secrets.sh and run again ..."
      #exit 1
   else  # secrets file found:
      h2 "Reading -secrets.sh in $SECRETS_FILEPATH ..."
      note "$(ls -al $SECRETS_FILEPATH )"
      chmod +x "$SECRETS_FILEPATH"
      source   "$SECRETS_FILEPATH"  # run file containing variable definitions.
      if [ "$CIRCLECI_API_TOKEN" == "xxx" ]; then 
         fatal "Please edit CIRCLECI_API_TOKEN in file \$HOME/.secrets.sh and run again ..."
         exit 9
      fi
   fi

   # TODO: Capture password manual input once for multiple shares 
   # (without saving password like expect command) https://www.linuxcloudvps.com/blog/how-to-automate-shell-scripts-with-expect-command/
      # From https://askubuntu.com/a/711591
   #   read -p "Password: " -s szPassword
   #   printf "%s\n" "$szPassword" | sudo --stdin mount \
   #      -t cifs //192.168.1.1/home /media/$USER/home \
   #      -o username=$USER,password="$szPassword"

fi  # if [ "${USE_SECRETS_FILE}" = false ]; then  # -s

         note "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}"
         note "GitHub_USER_NAME=\"${GitHub_USER_NAME}\" "
         note "GitHub_USER_EMAIL=\"${GitHub_USER_EMAIL}\" "


if [ "${USE_GOOGLE_CLOUD}" = true ]; then   # -g
   # Perhaps in https://console.cloud.google.com/cloudshell  (use on Chromebooks with no Terminal)
   # Comes with gcloud, node, docker, kubectl, go, python, git, vim, cloudshell dl file, etc.

      # See https://cloud.google.com/sdk/gcloud
      if ! command -v gcloud >/dev/null; then  # command not found, so:
         h2 "Installing gcloud CLI in google-cloud-sdk ..."
         brew cask install google-cloud-sdk
         # google-cloud-sdk is installed at /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk.
         # anthoscligcl
      else  # installed already:
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "Re-installing gcloud CLI in google-cloud-sdk ..."
            brew cask upgrade google-cloud-sdk
         fi
      fi
      note "$( gcloud --version | grep 'Google Cloud SDK' )"
         # Google Cloud SDK 280.0.0
         # bq 2.0.53
         # core 2020.02.07
         # gsutil 4.47

   # Set cursor to be consistently on left side after a blank line:
   export PS1="\n  \w\[\033[33m\]\n$ "
   note "$( ls )"

      h2 "gcloud info & auth list ..."
      GCP_AUTH=$( gcloud auth list )
      if [[ $GCP_AUTH == *"No credentialed accounts"* ]]; then
         gcloud auth login  # for pop-up browser auth.
      else
         echo "GCP_AUTH=$GCP_AUTH"
            #           Credentialed Accounts
            # ACTIVE  ACCOUNT
            # *       google462324_student@qwiklabs.net
      fi
      # To set the active account, run:
      # gcloud config set account `ACCOUNT`

   if [ -n "$PROJECT_NAME" ]; then   # variable is NOT empty
      h2 "Using -project $PROJECT_NAME ..."
      gcloud config set project "${PROJECT_NAME}"
   fi
   GCP_PROJECT=$( gcloud config list project | grep project | awk -F= '{print $2}' )
      # awk -F= '{print $2}'  extracts 2nd word in response:
      # project = qwiklabs-gcp-9cf8961c6b431994
      # Your active configuration is: [cloudshell-19147]
      if [[ $GCP_PROJECT == *"[default]"* ]]; then
         gcloud projects list
         exit 9
      fi

   PROJECT_ID=$( gcloud config list project --format "value(core.project)" )
      # Your active configuration is: [cloudshell-29462]
      #  qwiklabs-gcp-252d53a19c85b354
   info "GCP_PROJECT=$GCP_PROJECT, PROJECT_ID=$PROJECT_ID"
       # GCP_PROJECT= qwiklabs-gcp-00-3d1faad4cd8f, PROJECT_ID=qwiklabs-gcp-00-3d1faad4cd8f
   info "DEVSHELL_PROJECT_ID=$DEVSHELL_PROJECT_ID"

   RESPONSE=$( gcloud compute project-info describe --project $GCP_PROJECT )
      # Extract from:
      #items:
      #- key: google-compute-default-zone
      # value: us-central1-a
      #- key: google-compute-default-region
      # value: us-central1
      #- key: ssh-keys
   #note "RESPONSE=$RESPONSE"

   if [ "${RUN_VERBOSE}" = true ]; then
      h2 "gcloud info and versions ..."
      gcloud info
      gcloud version
         # git: [git version 2.11.0]
         docker --version  # Docker version 19.03.5, build 633a0ea838
         kubectl version
         node --version
         go version        # go version go1.13 linux/amd64
         python --version  # Python 2.7.13
         unzip -v | grep Debian   # UnZip 6.00 of 20 April 2009, by Debian. Original by Info-ZIP.

      gcloud config list
         # [component_manager]
         # disable_update_check = True
         # [compute]
         # gce_metadata_read_timeout_sec = 5
         # [core]
         # account = wilsonmar@gmail.com
         # disable_usage_reporting = False
         # project = qwiklabs-gcp-00-3d1faad4cd8f
         # [metrics]
         # environment = devshell
         # Your active configuration is: [cloudshell-17739]

      # TODO: Set region?
      # gcloud functions regions list
         # projects/.../locations/us-central1, us-east1, europe-west1, asia-northeast1

   fi

   # See https://cloud.google.com/blog/products/management-tools/scripting-with-gcloud-a-beginners-guide-to-automating-gcp-tasks
      # docker run --name web-test -p 8000:8000 crccheck/hello-world

   # To manage secrets stored in the Google cloud per https://wilsonmar.github.io/vault
   # enable APIs for your account: https://console.developers.google.com/project/123456789012/settings%22?pli=1
   gcloud services enable \
      cloudfunctions.googleapis.com \
      storage-component.googleapis.com
   # See https://cloud.google.com/functions/docs/securing/managing-access-iam


   # Setup Google's Local Functions Emulator to test functions locally without deploying the live environment every time:
   # npm install -g @google-cloud/functions-emulator
      # See https://rominirani.com/google-cloud-functions-tutorial-using-gcloud-tool-ccf3127fdf1a

fi



if [ "${DOWNLOAD_INSTALL}" = true ]; then  # -I

   h2 "-Install package managers ..."
   if [ "${PACKAGE_MANAGER}" == "brew" ]; then # -U

      # Install XCode for  Ruby Development Headers:
      # See https://stackoverflow.com/questions/20559255/error-while-installing-json-gem-mkmf-rb-cant-find-header-files-for-ruby/20561594
      # Ensure Apple's command line tools (such as cc) are installed by node:
      if ! command -v cc >/dev/null; then  # not installed, so:
         h2 "Installing Apple's xcode command line tools (this takes a while) ..."
         xcode-select --install 
         # NOTE: Xcode installs its git to /usr/bin/git; recent versions of OS X (Yosemite and later) ship with stubs in /usr/bin, which take precedence over this git. 
      fi
      note "$( xcode-select --version )"
         # XCode version: https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man1/pkgutil.1.html
         # pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep version
         # Tools_Executables | grep version
         # version: 9.2.0.0.1.1510905681
      # TODO: https://gist.github.com/tylergets/90f7e61314821864951e58d57dfc9acd

      if ! command -v brew ; then   # brew not recognized:
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

            if grep -q ".rbenv/bin:" "${BASHFILE}" ; then
               note ".rbenv/bin: already in ${BASHFILE}"
            else
               info "Adding .rbenv/bin: in ${BASHFILE} "
               echo "# .rbenv/bin are shims for Ruby commands so must be in front:" >>"${BASHFILE}"
               # shellcheck disable=SC2016 # Expressions don't expand in single quotes, use double quotes for that.
               echo "export PATH=\"$HOME/.rbenv/bin:$PATH\" " >>"${BASHFILE}"
               source "${BASHFILE}"
            fi

            if grep -q "brew shellenv" "${BASHFILE}" ; then
               note "brew shellenv: already in ${BASHFILE}"
            else
               info "Adding brew shellenv: in ${BASHFILE} "
               echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>"${BASHFILE}"
               source "${BASHFILE}"
            fi
         fi  # "$OS_TYPE" == "WSL"
      else  # brew found:
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "Updating brew itself ..."
            # per https://discourse.brew.sh/t/how-to-upgrade-brew-stuck-on-0-9-9/33 from 2016:
            # cd "$(brew --repo)" && git fetch && git reset --hard origin/master && brew update
            brew update
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
            sudo apt-get update
            sudo apt-get dist-upgrade
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
      note "$( yum --version )"

   #  TODO: elif for Suse Linux "${PACKAGE_MANAGER}" == "zypper" ?

   fi # PACKAGE_MANAGER

fi # if [ "${DOWNLOAD_INSTALL}"



if [ "${USE_GOOGLE_CLOUD}" = true ]; then   # -g

      # assume setup done by https://wilsonmar.github.io/gcp
      # See https://cloud.google.com/solutions/secrets-management
      # https://github.com/GoogleCloudPlatform/berglas is being migrated to Google Secrets Manager.
      # See https://github.com/sethvargo/secrets-in-serverless/tree/master/gcs to encrypt secrets on Google Cloud Storage accessed inside a serverless Cloud Function.
      # using gcloud beta secrets create "my-secret" --replication-policy "automatic" --data-file "/tmp/my-secret.txt"
      h2 "Retrieve secret version from GCP Cloud Secret Manager ..."
      gcloud beta secrets versions access "latest" --secret "my-secret"
         # A secret version contains the actual contents of a secret. "latest" is the VERSION_ID      

   h2 "In GCP create new repository using gcloud & git commands:"
   # gcloud source repos create REPO_DEMO

   # Clone the contents of your new Cloud Source Repository to a local repo:
   # gcloud source repos clone REPO_DEMO

   # Navigate into the local repository you created:
   # cd REPO_DEMO

   # Create a file myfile.txt in your local repository:
   # echo "Hello World!" > myfile.txt

   # Commit the file using the following Git commands:
   # git config --global user.email "you@example.com"
   # git config --global user.name "Your Name"
   # git add myfile.txt
   # git commit -m "First file using Cloud Source Repositories" myfile.txt

   # git push origin master
fi

pipenv_install() {
   # Pipenv is a dependency manager for Python projects like Node.js’ npm or Ruby’s bundler.
   # See https://realpython.com/pipenv-guide/
   # Pipenv combines pip & virtualenv in a single interface.

   if [ "${PACKAGE_MANAGER}" == "brew" ]; then
         # https://pipenv.readthedocs.io/en/latest/
         if ! command -v pipenv >/dev/null; then  # command not found, so:
            h2 "Brew installing pipenv ..."
            brew install pipenv
         else  # installed already:
            if [ "${UPDATE_PKGS}" = true ]; then
               h2 "Brew upgrading pipenv ..."
               brew upgrade pipenv
               # pip install --user --upgrade pipenv
            fi
         fi
         note "$( pipenv --version )"
            # pipenv, version 2018.11.26

      #elif for Alpine? 
      elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
         silent-apt-get-install "pipenv"  # please test
      elif [ "${PACKAGE_MANAGER}" == "yum" ]; then    # For Redhat distro:
         sudo yum install pipenv      # please test
      elif [ "${PACKAGE_MANAGER}" == "zypper" ]; then   # for [open]SuSE:
         sudo zypper install pipenv   # please test
      else
         fatal "Package Manager not recognized installing pipenv."
         exit
   fi  # PACKAGE_MANAGER

   # See https://pipenv-fork.readthedocs.io/en/latest/advanced.html#automatic-loading-of-env
   # PIPENV_DOTENV_LOCATION=/path/to/.env

     # TODO: if [ "${RUN_ACTUAL}" = true ]; then  # -a for production usage
         #   pipenv install some-pkg     # production
         # else
         #   pipenv install pytest -dev   # include Pipfile [dev-packages] components such as pytest

      if [ -f "Pipfile.lock" ]; then  
         # See https://github.com/pypa/pipenv/blob/master/docs/advanced.rst on deployments
         # Install based on what's in Pipfile.lock:
         h2 "Install based on Pipfile.lock ..."
         pipenv install --ignore-pipfile
      elif [ -f "Pipfile" ]; then  # found:
         h2 "Install based on Pipfile ..."
         pipenv install
      elif [ -f "setup.py" ]; then  
         h2 "Install a local setup.py into your virtual environment/Pipfile ..."
         pipenv install "-e ."
            # ✔ Successfully created virtual environment!
         # Virtualenv location: /Users/wilson_mar/.local/share/virtualenvs/python-samples-gTkdon9O
         # where "-gTkdon9O" adds the leading part of a hash of the full path to the project’s root.
      fi
}  # pipenv_install()


if [ "${INSTALL_AWS_CLIENT}" = true ]; then

   if [ "${PACKAGE_MANAGER}" == "brew" ]; then
      #fancy_echo "awscli requires Python3."
      # See https://docs.aws.amazon.com/cli/latest/userguide/cli-install-macos.html#awscli-install-osx-pip
      # PYTHON3_INSTALL  # function defined at top of this file.
      # :  # break out immediately. Not execute the rest of the if strucutre.
      # TODO: https://github.com/bonusbits/devops_bash_config_examples/blob/master/shared/.bash_aws
      # For aws-cli commands, see http://docs.aws.amazon.com/cli/latest/userguide/ 
      if ! command -v aws >/dev/null; then
         h2 "pipenv install awscli ..."
         pipenv install awscli --user  # no --upgrade 
      else
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "pipenv upgrade awscli ..."
            note "Before upgrade: $(aws --version)"  # aws-cli/2.0.9 Python/3.8.2 Darwin/19.4.0 botocore/2.0.0dev13
               # sudo rm -rf /usr/local/aws
               # sudo rm /usr/local/bin/aws
               # curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
               # unzip awscli-bundle.zip
               # sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
            pipenv install awscli --upgrade --user
         fi
      fi
      note "$( aws --version )"  # aws-cli/2.0.9 Python/3.8.2 Darwin/19.5.0 botocore/2.0.0dev13

   fi  # "${PACKAGE_MANAGER}" == "brew" ]; then

fi


if [ "${USE_AWS_CLOUD}" = true ]; then   # -w
   if [ "${USE_VAULT}" = true ]; then   # -w
      # Alternative: https://hub.docker.com/_/vault

      if [ "${PACKAGE_MANAGER}" == "brew" ]; then
         # See https://www.davehall.com.au/tags/bash
         if ! command -v aws-vault >/dev/null; then  # command not found, so:
            h2 "Brew cask installing aws-vault ..."
            brew cask install aws-vault  
         else  # installed already:
            if [ "${UPDATE_PKGS}" = true ]; then
               h2 "Brew cask upgrade aws-vault ..."
               note "aws-vault version $( aws-vault --version )"  # v5.3.2
               brew upgrade aws-vault
            fi
         fi
         note "aws-vault version $( aws-vault --version )"  # v5.3.2

      fi  # "${PACKAGE_MANAGER}" == "brew" ]; then

   fi  # if [ "${USE_VAULT}" = true 

fi  # USE_AWS_CLOUD


if [ "${USE_K8S}" = true ]; then  # -k8s

   h2 "-k8s"

   # See https://kubernetes.io/docs/tasks/tools/install-minikube/
   RESPONSE="$( sysctl -a | grep -E --color 'machdep.cpu.features|VMX' )"
   if [[ "${RESPONSE}" == *"VMX"* ]]; then  # contains it:
      note "VT-x feature needed to run Kubernetes is available!"
   else
      fatal "VT-x feature needed to run Kubernetes is NOT available!"
      exit 9
   fi

      if [ "${PACKAGE_MANAGER}" == "brew" ]; then

         if ! command -v minikube >/dev/null; then  # command not found, so:
            h2 "Brew cask installing minikube ..."
            brew install minikube  
         else  # installed already:
            if [ "${UPDATE_PKGS}" = true ]; then
               h2 "Brew cask upgrade minikube ..."
               note "minikube version $( minikube version )"  # minikube version: v1.11.0
               brew upgrade minikube
            fi
         fi
         note "minikube version $( minikube version )"  # minikube version: v1.11.0
             # commit: 57e2f55f47effe9ce396cea42a1e0eb4f611ebbd

      fi  # "${PACKAGE_MANAGER}" == "brew" 

exit

fi  # if [ "${USE_K8S}" = true ]; then  # -k8s



if [ "${RUN_EKS}" = true ]; then  # -EKS

   # h2 "kubectl client install for -EKS ..."
   if [ "${PACKAGE_MANAGER}" == "brew" ]; then
      # Use Homebrew instead of https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html
      # See https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
      # to communicate with the k8s cluster API server. 
         if ! command -v kubectl >/dev/null; then  # not found:
         h2 "kubectl install ..."
            brew install kubectl
         else  # installed already:
            if [ "${UPDATE_PKGS}" = true ]; then
               h2 "Brew upgrading kubectl ..."
               note "kubectl $( kubectl version --short --client )"  # Client Version: v1.16.6-beta.0
               brew upgrade kubectl
            fi
         fi
         note "kubectl $( kubectl version --short --client )"  # Client Version: v1.16.6-beta.0


      # See https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
         if ! command -v aws-iam-authenticator >/dev/null; then  # not found:
            h2 "aws-iam-authenticator install ..."
            brew install aws-iam-authenticator
            chmod +x ./aws-iam-authenticator
         else  # installed already:
            if [ "${UPDATE_PKGS}" = true ]; then
               h2 "Brew upgrading aws-iam-authenticator ..."
               note "aws-iam-authenticator version $( aws-iam-authenticator version )"  # {"Version":"v0.5.0","Commit":"1cfe2a90f68381eacd7b6dcfa2bf689e76eb8b4b"}
               brew upgrade aws-iam-authenticator
            fi
         fi
         note "aws-iam-authenticator version $( aws-iam-authenticator version )"  # {"Version":"v0.5.0","Commit":"1cfe2a90f68381eacd7b6dcfa2bf689e76eb8b4b"}
  

   ### h2 "eksctl install ..."
      # See https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html
         if ! command -v eksctl >/dev/null; then  # not found:
            h2 "eksctl install ..."
            brew tap weaveworks/tap
            brew install weaveworks/tap/eksctl
         else  # installed already:
            if [ "${UPDATE_PKGS}" = true ]; then
               h2 "Brew upgrading eksctl ..."
               note "eksctl version $( eksctl version )"  # 0.21.0
               brew tap weaveworks/tap
               brew upgrade eksctl && brew link --overwrite eksctl
            fi
         fi
         note "eksctl version $( eksctl version )"  # 0.21.0

   fi  # "${PACKAGE_MANAGER}" == "brew" ]; then

   h2 "aws iam get-user to check AWS credentials ... "
   # see https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html
   # Secrets from AWS Management Console https://console.aws.amazon.com/iam/
   # More variables at https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html
   
   # For AWS authentication, I prefer to individual variables rather than use static data in a 
   # named profile file referenced in the AWS_PROFILE environment variable 
   # per https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html

   # h2 "Working with AWS MFA ..."
   # See https://blog.gruntwork.io/authenticating-to-aws-with-environment-variables-e793d6f6d02e
   # Give it the ARN of your MFA device (123456789012) and 
   # MFA token (123456) from the Google Authenticator App or key fob:
   #RESPONSE_JSON="$( aws sts get-session-token \
   #   --serial-number "${AWS_MFA_ARN}" \
   #   --token-code 123456 \
   #   --duration-seconds 43200 )"

   #RESPONSE_JSON="$( aws sts assume-role \
   #   --role-arn arn:aws:iam::123456789012:role/dev-full-access \
   #   --role-session-name username@company.com \
   #   --serial-number "${AWS_SERIAL_ARN}" \
   #   --token-code 123456 \
   #   --duration-seconds 43200  # 12 hours max.
   #)"

   # See https://aws.amazon.com/blogs/aws/aws-identity-and-access-management-policy-simulator/
   # See http://awsdocs.s3.amazonaws.com/EC2/ec2-clt.pdf = AWS EC2 CLI Reference

   RESPONSE="$( aws iam get-user )"
      # ERROR: Unable to locate credentials. You can configure credentials by running "aws configure".
      # This script stops if there is a problem here.
   note "$( echo ${RESPONSE} | jq )"

   h2 "Create cluster $EKS_CLUSTER_NAME using eksctl ... "
   # See https://eksctl.io/usage/creating-and-managing-clusters/
   # NOT USED: eksctl create cluster -f "${EKS_CLUSTER_FILE}"  # cluster.yaml

exit
   eksctl create cluster -v \
        --name="${EKS_CLUSTER_NAME}" \
        --region="${AWS_DEFAULT_REGION}" \
        --ssh-public-key="${EKS_KEY_FILE_PREFIX}" \
        --nodes="${EKS_NODES}" \  # --nodes-min=, --nodes-max=  # to config K8s Cluster autoscaler to automatically adjust the number of nodes in your node groups.
        --node_type="${EKS_NODE_TYPE}" \
        --fargate \
        # --version 1.16 \  # of kubernetes (1.16)
        --write-kubeconfig="${EKS_CRED_IS_LOCAL}" \
        --set-kubeconfig-context=false
   # RESPONSE: setting availability zones to go with region specified.
   # using official AWS EKS EC2 AMI, static AMI resolver, dedicated VPC
      # creating cluster stack "eksctl-v-cluster" to ${EKS_CLUSTER_NAME}
      # launching CloudFormation stacks "eksctl-v-nodegroup-0" to ${EKS_NODEGROUP_ID}
      # [ℹ]  nodegroup "ng-eb501ec0" will use "ami-073f227b0cd9507f9" [AmazonLinux2/1.16]
      # [ℹ]  using Kubernetes version 1.16
      # [ℹ]  creating EKS cluster "ridiculous-creature-1591935726" in "us-east-2" region with un-managed nodes
      # [ℹ]  will create 2 separate CloudFormation stacks for cluster itself and the initial nodegroup
      # [ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=us-east-2 --cluster=ridiculous-creature-1591935726'
      # [ℹ]  CloudWatch logging will not be enabled for cluster "ridiculous-creature-1591935726" in "us-east-2"
      # [ℹ]  you can enable it with 'eksctl utils update-cluster-logging --region=us-east-2 --cluster=ridiculous-creature-1591935726'
      # [ℹ]  Kubernetes API endpoint access will use default of {publicAccess=true, privateAccess=false} for cluster "ridiculous-creature-1591935726" in "us-east-2"
      # [ℹ]  2 sequential tasks: { create cluster control plane "ridiculous-creature-1591935726", 2 sequential sub-tasks: { no tasks, create nodegroup "ng-eb501ec0" } }
      # [ℹ]  building cluster stack "eksctl-ridiculous-creature-1591935726-cluster"

   # After about 10-15 minutes:

   if [ "${EKS_CRED_IS_LOCAL}" == true ]; then
      if [ -f "$HOME/.kube/config" ]; then  # file exists:
         # If file exists in "$HOME/.kube/config" for cluster credentials
         h2 "kubectl get nodes ..."
         kubectl --kubeconfig .kube/config  get nodes
      else
         note "No $HOME/.kube/config, so create folder ..."
         sudo mkdir ~/.kube
         #sudo cp /etc/kubernetes/admin.conf ~/.kube/
         # cd ~/.kube
         #sudo mv admin.conf config
         #sudo service kubelet restart
      fi
   fi

   # https://github.com/cloudacademy/Store2018
   # git clone https://github.com/cloudacademy/Store2018/tree/master/K8s
   # from https://hub.docker.com/u/jeremycookdev/ 
       # deployment/
       #   store2018.service.yaml 
       #   store2018.inventoryservice.yaml
       #   store2018.accountservice.yaml
       #   store2018.yaml  # specifies host names
       # service/  # loadbalancers
       #   store2018.accountservice.service.yaml   = docker pull jeremycookdev/accountservice
       #   store2018.inventoryservice.service.yaml = docker pull jeremycookdev/inventoryservice
       #   store2018.service.yaml                  = docker pull jeremycookdev/store2018
       #   store2018.shoppingservice.service.yaml  = docker pull jeremycookdev/shoppingservice
   # kubectl apply -f store2018.yml

   # kubectl get services --all-namespaces -o wide

      # NAMESPACE       NAME             TYPE          CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
      # default         svc/kubernetes   ClusterIP     10.100.0.1     <none>          443/TCP        10m
      # kube-system     kube-dns         ClusterIP     10.100.0.10    <none>          53/UDP.53/TCP  10m
      # store2018                        LoadBalancer  10.100.77.214  281...amazon..  80:31318/TCP   26s

   # kubectl get deployments
      # NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
      # store-service  3         3         3            3           31s

   # kubectl get pods   # to deployment 
      # NAME  READY   STATUS   RESTARTS   AGE
      # ....  1/1     Running  0          31s

   # If using Linux accelerated AMI instance type and the Amazon EKS-optimized accelerated AMI
   #  apply the NVIDIA device plugin for Kubernetes as a DaemonSet on the cluster:
   # kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/1.0.0-beta/nvidia-device-plugin.yml

   # h2 "Opening EKS Clusters web page ..."
   # open https://${AWS_DEFAULT_REGION}.console.aws.amazon.com/eks/home?region=${AWS_DEFAULT_REGION}#/clusters

   # h2 "Opening EKS Worker Nodes in EC2 ..."
   # open https://${AWS_DEFAULT_REGION}.console.aws.amazon.com/ec2/v2/home?region=${AWS_DEFAULT_REGION}#instances;sort=tag:Name

   # h2 "Listing resources ..."  # cluster, security groups, IAM policy, route, subnet, vpc, etc.
   # note $( aws cloudformation describe-stack-resources --region="${AWS_DEFAULT_REGION}" \
   #      --stack-name="${EKS_CLUSTER_NAME}" )

   # h2 "Listing node group info ..."  # Egress, InstanceProfile, LaunchConfiguration, IAM:Policy, SecurityGroup
   # note $( aws cloudformation describe-stack-resources --region="${AWS_DEFAULT_REGION}" \
   #      --stack-name="${EKS_NODEGROUP_ID}" )

   # Install Splunk Forwarding from https://docs.aws.amazon.com/eks/latest/userguide/metrics-server.html

   # Install CloudWatch monitoring

   # Performance testing using ab (apache bench)

   if [ "$DELETE_CONTAINER_AFTER" = true ]; then  # -D
 
      kubectl delete deployments --all
      kubectl get pods

      kubectl delete services --all   # load balancers
      kubectl get services
   
      eksctl get cluster 
      eksctl delete cluster "${EKS_CLUSTER_NAME}"

      if [ -f "$HOME/.kube/config" ]; then  # file exists:
           rm "$HOME/.kube/config"
      fi

   fi   # if [ "$DELETE_CONTAINER_AFTER" = true ]; then  # -D

exit  # DEBUGGING

fi  # EKS


if [ "${USE_AZURE_CLOUD}" = true ]; then   # -z
      # See https://docs.microsoft.com/en-us/cli/azure/keyvault/secret?view=azure-cli-latest
      brew cask install azure-vault
fi


Delete_GitHub_clone(){
   # https://www.shellcheck.net/wiki/SC2115 Use "${var:?}" to ensure this never expands to / .
   PROJECT_FOLDER_FULL_PATH="${PROJECT_FOLDER_PATH}/${GitHub_REPO_NAME}"
   if [ -d "${PROJECT_FOLDER_FULL_PATH:?}" ]; then  # path available.
      h2 "Removing project folder $PROJECT_FOLDER_FULL_PATH ..."
      ls -al "${PROJECT_FOLDER_FULL_PATH}"
      rm -rf "${PROJECT_FOLDER_FULL_PATH}"
   fi
}
Clone_GitHub_repo(){
      git clone "${GitHub_REPO_URL}" "${GitHub_REPO_NAME}"
      cd "${GitHub_REPO_NAME}"
      note "At $PWD"
}

if [ "${CLONE_GITHUB}" = true ]; then   # -clone specified:

   if [ -z "${GitHub_REPO_NAME}" ]; then   # name not specified:
      fatal "GitHub_REPO_NAME not specified ..."
      exit
   fi 

   if [ -z "${PROJECT_FOLDER_PATH}" ]; then   # No name specified:
      fatal "PROJECT_FOLDER_PATH not specified ..."
      exit
   fi 

   PROJECT_FOLDER_FULL_PATH="${PROJECT_FOLDER_PATH}/${GitHub_REPO_NAME}"
   h2 "-clone requested for $GitHub_REPO_URL $GitHub_REPO_NAME ..."
   if [ -d "${PROJECT_FOLDER_FULL_PATH:?}" ]; then  # path available.
      rm -rf "$GitHub_REPO_NAME" 
      Delete_GitHub_clone    # defined above in this file.
   fi

   Clone_GitHub_repo      # defined above in this file.
      # curl -s -O https://raw.GitHubusercontent.com/wilsonmar/build-a-saas-app-with-flask/master/sample.sh
      # git remote add upstream https://github.com/nickjj/build-a-saas-app-with-flask
      # git pull upstream master

else   # do not -clone
   if [ -d "${GitHub_REPO_NAME}" ]; then  # path available.
      h2 "Re-using repo ${GitHub_REPO_URL} ${GitHub_REPO_NAME} ..."
      cd "${GitHub_REPO_NAME}"
   else
      h2 "Git cloning repo ${GitHub_REPO_URL} ${GitHub_REPO_NAME} ..."
      # Clone_GitHub_repo      # defined above in this file.
      note "$( ls $PWD )"
   fi
fi


   if [ -z "$GitHub_USER_EMAIL" ]; then   # variable is blank
      Input_GitHub_User_Info  # function defined above.
   else
      note "Using -u \"$GitHub_USER_NAME\" -e \"$GitHub_USER_EMAIL\" ..."
      # since this is hard coded as "John Doe" above
   fi


if [ "${USE_SECRETS_FILE}" = true ]; then   # -S

   # This is https://github.com/AGWA/git-crypt      has 4,500 stars.
   # Whereas https://github.com/sobolevn/git-secret has 1,700 stars.
   # This script detects whether https://github.com/sobolevn/git-secret was used to store secrets inside a local git repo.
   # This looks in the repo .gitsecret folder created by the "git secret init" command on this repo (under DevSecOps).
   # "git secret tell" stores the public key of the current git user email.
   # "git secret add my-file.txt" then "git secret hide" and "rm my-file.txt"
   # This approach is not real secure because it's a matter of time before any static secret can be decrypted by brute force.
   # When someone is out - delete their public key, re-encrypt the files, and they won’t be able to decrypt secrets anymore.
   if [ -d ".gitsecret" ]; then   # found
        h2 ".gitsecret folder found ..."
      # Files in there were encrypted using "git-secret" commands referencing gpg gen'd key pairs based on an email address.
      if [ "${PACKAGE_MANAGER}" == "brew" ]; then
         if ! command -v gpg >/dev/null; then  # command not found, so:
            h2 "Brew installing gnupg ..."
            brew install gnupg  
         else  # installed already:
            if [ "${UPDATE_PKGS}" = true ]; then
               h2 "Brew upgrading gnupg ..."
               brew upgrade gnupg
            fi
         fi
         note "$( gpg --version )"  # 2.2.19
         # See https://github.com/sethvargo/secrets-in-serverless using kv or aws (iam) secrets engine.

         if ! command -v git-secret >/dev/null; then  # command not found, so:
            h2 "Brew installing git-secret ..."
            brew install git-secret  
         else  # installed already:
            if [ "${UPDATE_PKGS}" = true ]; then
               h2 "Brew upgrading git-secret ..."
               brew upgrade git-secret
            fi
         fi
         note "$( git-secret --version )"  # 0.3.2

      elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
         silent-apt-get-install "gnupg"
      elif [ "${PACKAGE_MANAGER}" == "yum" ]; then    # For Redhat distro:
         sudo yum install gnupg      # please test
      elif [ "${PACKAGE_MANAGER}" == "zypper" ]; then   # for [open]SuSE:
         sudo zypper install gnupg   # please test
      else
         git clone https://github.com/sobolevn/git-secret.git
         cd git-secret && make build
         PREFIX="/usr/local" make install      
      fi  # PACKAGE_MANAGER

      if [ -f "${SECRETS_FILE}.secret" ]; then   # found
         h2 "${SECRETS_FILE}.secret being decrypted using the private key in the bash user's local $HOME folder"
         git secret reveal
            # gpg ...
         if [ -f "${SECRETS_FILE}" ]; then   # found
            h2 "File ${SECRETS_FILE} decrypted ..."
         else
            fatal "File ${SECRETS_FILE} not decrypted ..."
            exit 9
         fi
      fi 
   fi  # .gitsecret

   #if [ ! -f "docker-compose.override.yml" ]; then
   #   cp docker-compose.override.example.yml  docker-compose.override.yml
   #else
   #   warning "no .yml file"
   #fi

fi  # USE_SECRETS_FILE  to get into cloud



if [ "${USE_AZURE_CLOUD}" = true ]; then   # -z
   h2 "Azure cloud "  # https://docs.microsoft.com/en-us/azure/key-vault/about-keys-secrets-and-certificates
fi



if [ "${USE_GOOGLE_CLOUD}" = true ]; then   # -g

   # https://google.qwiklabs.com/games/759/labs/2373
   h2 "Using GCP for Speech-to-Text API"  # https://cloud.google.com/speech/reference/rest/v1/RecognitionConfig
   # usage limits: https://cloud.google.com/speech-to-text/quotas
   curl -O -s "https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/gcp/gcp-speech-to-text/request.json"
   cat request.json
   # Listen to it at: https://storage.cloud.google.com/speech-demo/brooklyn.wav
   
   curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
      "https://speech.googleapis.com/v1/speech:recognize?key=${GOOGLE_API_KEY}" > result.json
   cat result.json

exit  # in dev

   # https://google.qwiklabs.com/games/759/labs/2374
   h2 "GCP AutoML Vision API"
   # From the Navigation menu and select APIs & Services > Library https://cloud.google.com/automl/ui/vision
   # In the search bar type in "Cloud AutoML". Click on the Cloud AutoML API result and then click Enable.

   QWIKLABS_USERNAME="???"

   # Give AutoML permissions:
   gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member="user:$QWIKLABS_USERNAME" \
    --role="roles/automl.admin"

   gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member="serviceAccount:custom-vision@appspot.gserviceaccount.com" \
    --role="roles/ml.admin"

   gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member="serviceAccount:custom-vision@appspot.gserviceaccount.com" \
    --role="roles/storage.admin"

   # TODO: more steps needed from lab

fi


if [ "${USE_CIRCLECI}" = true ]; then   # -L
   # https://circleci.com/docs/2.0/getting-started/#setting-up-circleci
   # h2 "circleci setup ..."

   # Using variables from env file:
   h2 "circleci setup ..."
   if [ -n "${CIRCLECI_API_TOKEN}" ]; then  
      if ! command -v circleci ; then
         h2 "Installing circleci ..."
   # No brew:
         curl -fLSs https://circle.ci/cli | bash
      else
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "Removing and installing circleci ..."
            rm -rf "/usr/local/bin/circleci"
            curl -fLSs https://circle.ci/cli | bash
         fi
      fi
      note "circleci version = $( circleci version)"   # 0.1.7179+e661c13
      # https://github.com/CircleCI-Public/circleci-cli

      if [ -f "$HOME/.circleci/cli.yml" ]; then
         note "Using existing $HOME/.circleci/cli.yml ..."
      else
         circleci setup --token "${CIRCLECI_API_TOKEN}" --host "https://circleci.com"
      fi
   else
      error "CIRCLECI_API_TOKEN missing. Aborting ..."
      exit 9
   fi

   h2 "Loading Circle CI config.yml ..."
   mkdir -p "$HOME/.circleci"

   echo "-f MY_FILE=$MY_FILE"
   if [ -z "${MY_FILE}" ]; then   # -f not specified:
      note "-file not specified. Using config.yml from repo ... "
      # copy with -force to update:
      cp -f ".circleci/config.yml" "$HOME/.circleci/config.yml"
   elif [ -f "${MY_FILE}" ]; then 
      fatal "${MY_FILE} not found ..."
      exit 9
   else
      mv "${MY_FILE}" "$HOME/.circleci/config.yml"
   fi

   if [ ! -f "$HOME/.circleci/config.yml" ]; then 
      ls -al "$HOME/.circleci/config.yml"
      fatal "$HOME/.circleci/config.yml not found. Aborting ..."
      exit 9
   fi
   h2 "Validate Circle CI ..."
   circleci config validate

   h2 "??? Run Circle CI ..."  # https://circleci.com/docs/2.0/local-cli/
   # circleci run ???

   h2 "Done with Circle CI ..."
   exit
fi  # USE_CIRCLECI



if [ "${USE_YUBIKEY}" = true ]; then   # -Y
      if [ "${PACKAGE_MANAGER}" == "brew" ]; then
         if ! command -v ykman >/dev/null; then  # command not found, so:
            note "Brew installing ykman ..."
            brew install ykman
         else  # installed already:
            if [ "${UPDATE_PKGS}" = true ]; then
               note "Brew upgrading ykman ..."
               brew upgrade ykman
            fi
         fi
      elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
         silent-apt-get-install "ykman"
      elif [ "${PACKAGE_MANAGER}" == "yum" ]; then    # For Redhat distro:
         sudo yum install ykman      ; echo "TODO: please test"
         exit 9                      
      elif [ "${PACKAGE_MANAGER}" == "zypper" ]; then   # for [open]SuSE:
         sudo zypper install ykman   ; echo "TODO: please test"
         exit 9
      fi
      note "$( ykman --version )"
         # RESPONSE: YubiKey Manager (ykman) version: 3.1.1


      if [ "${PACKAGE_MANAGER}" == "brew" ]; then
         if ! command -v yubico-piv-tool >/dev/null; then  # command not found, so:
            note "Brew installing yubico-piv-tool ..."
            brew install yubico-piv-tool
         else  # installed already:
            if [ "${UPDATE_PKGS}" = true ]; then
               note "Brew upgrading yubico-piv-tool ..."
               brew upgrade yubico-piv-tool
            fi
         fi
         #  /usr/local/Cellar/yubico-piv-tool/2.0.0: 18 files, 626.7KB

      elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
         silent-apt-get-install "yubico-piv-tool"
      elif [ "${PACKAGE_MANAGER}" == "yum" ]; then    # For Redhat distro:
         sudo yum install yubico-piv-tool      ; echo "TODO: please test"
         exit 9                      
      elif [ "${PACKAGE_MANAGER}" == "zypper" ]; then   # for [open]SuSE:
         sudo zypper install yubico-piv-tool   ; echo "TODO: please test"
         exit 9
      fi
      note "$( yubico-piv-tool --version )"   # RESPONSE: yubico-piv-tool 2.0.0


   # TODO: Verify code below
   h2 "PIV application reset to remove all existing keys ..."
   ykman piv reset
      # RESPONSE: Resetting PIV data...

   h2 "Generating new certificate ..."
   yubico-piv-tool -a generate -s 9c -A RSA2048 --pin-policy=once --touch-policy=never -o public.pem
   yubico-piv-tool -a verify  -S "/CN=SSH key/" -a selfsign -s 9c -i public.pem -o cert.pem
   yubico-piv-tool -a import-certificate -s 9c -i cert.pem

   h2 "Export SSH public key ..."
   ssh-keygen -f public.pem -i -mPKCS8 | tee ./yubi.pub

   h2 "Sign key on CA using vault ..."
   vault write -field=signed_key  "${SSH_CLIENT_SIGNER_PATH}/sign/oleksii_samorukov public_key=@./yubi.pub" \
      | tee ./yubi-cert.pub

   h2 "Test whethef connection is working ..."
   ssh  git@github.com -I /usr/local/lib/libykcs11.dylib -o "CertificateFile ./yubi-cert.pub"

fi  # USE_YUBIKEY



if [ "${USE_VAULT}" = true ]; then   # -H
      h2 "-HashicorpVault being used ..."

      # See https://learn.hashicorp.com/vault/getting-started/install for install video
          # https://learn.hashicorp.com/vault/secrets-management/sm-versioned-kv
          # https://www.vaultproject.io/api/secret/kv/kv-v2.html
      # NOTE: vault-cli is a Subversion-like utility to work with Jackrabbit FileVault (not Hashicorp Vault)
      if [ "${PACKAGE_MANAGER}" == "brew" ]; then
         if ! command -v vault >/dev/null; then  # command not found, so:
            note "Brew installing vault ..."
            brew install vault
            # vault -autocomplete-install
            # exec $SHELL
         else  # installed already:
            if [ "${UPDATE_PKGS}" = true ]; then
               note "Brew upgrading vault ..."
               brew upgrade vault
               # vault -autocomplete-install
               # exec $SHELL
            fi
         fi
      elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
         silent-apt-get-install "vault"
      elif [ "${PACKAGE_MANAGER}" == "yum" ]; then    # For Redhat distro:
         sudo yum install vault      # please test
         exit 9
      elif [ "${PACKAGE_MANAGER}" == "zypper" ]; then   # for [open]SuSE:
         sudo zypper install vault   # please test
         exit 9
      fi
      RESPONSE="$( vault --version | cut -d' ' -f2 )"  # 2nd column of "Vault v1.3.4"
      export VAULT_VERSION="${RESPONSE:1}"   # remove first character.
      note "VAULT_VERSION=$VAULT_VERSION"   
      
      # Instead of vault -autocomplete-install   # for interactive manual use.
      # The complete command inserts in $HOME/.bashrc and .zsh
      complete -C /usr/local/bin/vault vault
         # No response is expected. Requires running exec $SHELL to work.

   if [ "${RUN_TESTS}" = true ]; then   # -t
      # CAUTION: Vault dev server is insecure and stores all data in memory only!

      h2 "Starting vault local dev server at $VAULT_ADDR ..."  # https://learn.hashicorp.com/vault/getting-started/dev-server
      ps_kill 'vault'  # bash function defined in this file.
      # Don't RESPONSE="$( vault server -dev  & )"  # & = background job
      # because this displays Unseal Key and Root Token:
                    vault server -dev
      # THIS SCRIPT PAUSES HERE. OPEN ANOTHER TERMINAL SESSION.
      # Press control+C to stop service.

      # echo -e "RESPONSE=$RESPONSE \n"

      # FIXME: capture output:
      export UNSEAL_KEY="$( echo "${RESPONSE}" | grep -o 'Unseal Key: [^, }]*' | sed 's/^.*: //' )"
      export VAULT_DEV_ROOT_TOKEN_ID="$( echo "${RESPONSE}" | grep -o 'Root Token: [^, }]*' | sed 's/^.*: //' )"
      note -e ">>> UNSEAL_KEY=$UNSEAL_KEY \n"
      note -e ">>> VAULT_DEV_ROOT_TOKEN_ID=$VAULT_DEV_ROOT_TOKEN_ID \n"
      #sample      VAULT_DEV_ROOT_TOKEN_ID="s.Lgsh7FXX9cUKQttfFo1mdHjE"

   fi  # RUN_TESTS


   if [ "${RUN_ACTUAL}" = true ]; then   # -a
      # use production ADDR from secrets
      if [ -z "${VAULT_ADDR}" ]; then  # it's blank:
         error "VAULT_ADDR is not defined (within secrets file) ..."
      else
         if ! ping -c 1 "${VAULT_ADDR}" &> /dev/null ; then 
            error "VAULT_ADDR=$VAULT_ADDR ICMP ping failed. Aborting ..."
            info  "Is VPN (GlobalProtect) running and you're loggin in?"
            # exit
         fi
      fi
      # export VAULT_ADDR=http://127.0.0.1:8200   # from Roman
      export VAULT_NAME="prodservermode"  # ???
   else  # test:
      export VAULT_ADDR=http://127.0.0.1:8200
      export VAULT_NAME="devservermode"
   fi  # RUN_ACTUAL

   note -e "\n"
   # Output to JSON instead & use jq to parse?
   RESPONSE="$( vault status 2>&2)"  # capture STDERR output to &1 (STDOUT)
         # See https://stackoverflow.com/questions/2990414/echo-that-outputs-to-stderr
         # STDERR: Error checking seal status: Get https://vault..../v1/sys/seal-status: dial tcp: lookup vault....: no such host
   ERR_RESPONSE="$( echo $RESPONSE | awk '{print $1;}' )"
   # TODO: Check error code.
   if [ "Error" = "$ERR_RESPONSE" ]; then
         fatal "${ERR_RESPONSE}"
         exit
   else
         note -e ">>> $RESPONSE"
   fi

   if [ -n "${VAULT_USERNAME}" ]; then  # is not empty
      note "Vault login as ${VAULT_USERNAME} ..."
      vault login -method=okta username="${VAULT_USERNAME}"  # from secrets.sh
         # Put https://127.0.0.1:8200/v1/auth/okta/login: dial tcp 127.0.0.1:8200: connect: connection refused
   fi

   note -e "\n Put secret/hello ..."
   note -e "\n"
   # Make CLI calls to the kv secrets engine for key/value pair:
   vault kv put secret/hello vault="${VAULT_NAME}"
      
   note -e "\n Get secret/hello text ..."
   note -e "\n"
   vault kv get secret/hello  # to system variable for .py program.
         # See https://www.vaultproject.io/docs/commands/index.html

   #note -e "\n Get secret/hello as json ..."
   #note -e "\n"
   #vault kv get -format=json secret/hello | jq -r .data.data.excited
   #note -e "\n Cat secret/hello from json ..."
   #cat .data.data.excited

   note -e "\n Enable userpass method ..."
   note -e "\n"
   vault auth enable userpass  # is only done once.
      # Success! Enabled userpass auth method at: userpass/

      #### "Installing govaultenv ..."
      if [ "${PACKAGE_MANAGER}" == "brew" ]; then
         # https://github.com/jamhed/govaultenv
         if ! command -v govaultenv >/dev/null; then  # command not found, so:
            h2 "Brew installing govaultenv ..."
            brew tap jamhed/govaultenv https://github.com/jamhed/govaultenv
            brew install govaultenv
         else  # installed already:
            if [ "${UPDATE_PKGS}" = true ]; then
               h2 "Brew upgrading govaultenv ..."
               brew tap jamhed/govaultenv https://github.com/jamhed/govaultenv
               brew upgrade jamhed/govaultenv/govaultenv
            fi
         fi
         note "govaultenv $( govaultenv | grep version | cut -d' ' -f1 )"
            # version:0.1.2 commit:d7754e38bb855f6a0c0c259ee2cced29c86a4da5 build by:goreleaser date:2019-11-13T19:47:16Z

      #elif for Alpine? 
      elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
         silent-apt-get-install "govaultenv"  # please test
      elif [ "${PACKAGE_MANAGER}" == "yum" ]; then    # For Redhat distro:
         sudo yum install govaultenv      # please test
      elif [ "${PACKAGE_MANAGER}" == "zypper" ]; then   # for [open]SuSE:
         sudo zypper install govaultenv   # please test
      else
         fatal "Package code not recognized."
         exit
      fi

      export VAULT_GOVC=team/env
      h2 "govaultenv run $VAULT_GOVC ..."
      govaultenv -verbose=debug /bin/bash

fi  # USE_VAULT



if [ "${MOVE_SECURELY}" = true ]; then   # -m
   # See https://github.com/settings/keys 
   # See https://github.blog/2019-08-14-ssh-certificate-authentication-for-github-enterprise-cloud/
   
   LOCAL_SSH_KEYFILE="test-ssh"
   if [ ! -f "${LOCAL_SSH_KEYFILE}" ]; then  # not exists
      h2 "Generating SSH key file $LOCAL_SSH_KEYFILE ..."
      ssh-keygen -t rsa -f "${LOCAL_SSH_KEYFILE}" -N ""
   else
      h2 "Using existing SSH key file ${LOCAL_SSH_KEYFILE}"
   fi
   note "$( ls -al ${LOCAL_SSH_KEYFILE} )"
 
   # Instead of pbcopy and paste in GitHub.com GUI, use obtain and use SSH certificate from a SSH CA:

   CA_KEY_FULLPATH="./ca_key"  # "~/.ssh/ca_key"  # "./ca_key" for current (project) folder  
   if [ ! -f "${CA_KEY_FULLPATH}" ]; then  # not exists
      h2 "CA key file $CA_KEY_FULLPATH not found, so generating for ADMIN ..."
      ssh-keygen -t rsa -f "${CA_KEY_FULLPATH}" -N ""
      # see https://unix.stackexchange.com/questions/69314/automated-ssh-keygen-without-passphrase-how

      h2 "ADMIN: In GitHub.com GUI SSH Certificate Authorities, manually click New CA and paste CA cert. ..."
      # On macOS
         cat "${CA_KEY_FULLPATH}.pub" | pbcopy
         open https://github.com/organizations/Mck-Internal-Test/settings/security
      # On Windows
         ## ???
      # Linux: See https://www.ostechnix.com/how-to-use-pbcopy-and-pbpaste-commands-on-linux/
      read -t 30 -p "Pausing -t 30 seconds to import ${LOCAL_SSH_KEYFILE} in GitHub.com GUI ..."

   else
      info "Using existing CA key file $CA_KEY_FULLPATH ..."
   fi
   note "$( ls -al ${CA_KEY_FULLPATH} )"


   # Using GitHub_ACCOUNT (as SSH Key Identity) from ./secrets.sh ...
      h2 "Signing user ${GitHub_ACCOUNT} public key file ${LOCAL_SSH_KEYFILE} ..."
      ssh-keygen -s "${CA_KEY_FULLPATH}" -I "${GitHub_ACCOUNT}" \
         -O "extension:login@github.com=${GitHub_ACCOUNT}" "${LOCAL_SSH_KEYFILE}.pub"
      # RESPONSE: Signed user key test-ssh-cert.pub: id "wilson-mar" serial 0 valid forever
      SSH_CERT_PUB_KEYFILE="${LOCAL_SSH_KEYFILE}-cert.pub"
      if [ ! -f "${SSH_CERT_PUB_KEYFILE}" ]; then  # not exists
         error "File ${SSH_CERT_PUB_KEYFILE} not found ..."
      else
         note "File ${SSH_CERT_PUB_KEYFILE} found ..."
         note "$( ls -al ${SSH_CERT_PUB_KEYFILE} )"
      fi

   # According to https://help.github.com/en/github/setting-up-and-managing-organizations-and-teams/about-ssh-certificate-authorities
   # To issue a certificate for someone who has different usernames for GitHub Enterprise Server and GitHub Enterprise Cloud, 
   # you can include two login extensions.
   # ssh-keygen -s ./ca-key -I KEY-IDENTITY \
   #    -O extension:login@github.com=CLOUD-USERNAME extension:login@

   if [ "${USE_VAULT}" = false ]; then   # -H
      h2 "Use GitHub extension to sign user public key with 1d Validity for ${GitHub_ACCOUNT} ..."
      ssh-keygen -s "${CA_KEY_FULLPATH}" -I "${GitHub_ACCOUNT}" \
         -O "extension:login@github.com=${GitHub_ACCOUNT}" -V '+1d' "${LOCAL_SSH_KEYFILE}.pub"
         # 1m = 1minute, 1d = 1day
         # -n user1 user1.pub
         # RESPONSE: Signed user key test-ssh-cert.pub: id "wilsonmar" serial 0 valid from 2020-05-23T12:59:00 to 2020-05-24T13:00:46

   else  # USE_VAULT
      # See https://www.vaultproject.io/docs/secrets/ssh/signed-ssh-certificates.html

      # From -secrets opening ~/.secrets.sh :
      note "$( VAULT_ADDR=$VAULT_ADDR )"
      note "$( VAULT_TLS_SERVER=$VAULT_TLS_SERVER )"
      note "$( VAULT_SERVERS=$VAULT_SERVERS )"
      note "$( CONSUL_HTTP_ADDR=$CONSUL_HTTP_ADDR )"

      SSH_CLIENT_SIGNER_PATH="ssh-client-signer"

      # Assuming Vault was enabled earlier in this script.
      h2 "Create SSH CA ..."
      vault secrets enable -path="${SSH_CLIENT_SIGNER_PATH}"  ssh
      vault write "${SSH_CLIENT_SIGNER_PATH}/config/ca"  generate_signing_key=true

      SSH_ROLE_FILENAME="myrole.json"
      SSH_USER_ROLE="oleksii_samorukov"
      echo -e "{" >"${SSH_ROLE_FILENAME}"
      echo -e "  \"allow_user_certificates\": true," >>"${SSH_ROLE_FILENAME}"
      echo -e "  \"allow_users\": \"*\"," >>"${SSH_ROLE_FILENAME}"
      echo -e "  \"default_extensions\": [" >>"${SSH_ROLE_FILENAME}"
      echo -e "    {" >>"${SSH_ROLE_FILENAME}"
      echo -e "      \"login@github.com\": \"$SSH_USER_ROLE\" " >>"${SSH_ROLE_FILENAME}"
      echo -e "    }" >>"${SSH_ROLE_FILENAME}"
      echo -e "  ]," >>"${SSH_ROLE_FILENAME}"
      echo -e "  \"key_type\": \"ca\"," >>"${SSH_ROLE_FILENAME}"
      echo -e "  \"default_user\": \"ubuntu\"," >>"${SSH_ROLE_FILENAME}"
      echo -e "  \"ttl\": \"30m0s\"" >>"${SSH_ROLE_FILENAME}"
      echo -e "}" >>"${SSH_ROLE_FILENAME}"

      h2 "Create user role ${SSH_USER_ROLE} with GH mapping ..."
      vault write "${SSH_CLIENT_SIGNER_PATH}/roles/${SSH_USER_ROLE}" @myrole.json

      h2 "Sign user public certificate and inspect it ..."
      vault write -field=signed_key  "${SSH_CLIENT_SIGNER_PATH}/roles/${SSH_USER_ROLE}"  "public_key=@./${LOCAL_SSH_KEYFILE}.pub" \
         | tee "${SSH_CERT_PUB_KEYFILE}"

      h2 "Inspect ${SSH_CERT_PUB_KEYFILE} ..."
      ssh-keygen -L -f "${SSH_CERT_PUB_KEYFILE}"

      h2 "Verify use of Vault SSH cert ..."
      ssh git@github.com  # (ssh would automatically use `test-ssh-cert.pub` file)

   fi  # if [ "${USE_VAULT}" = true ]


   if [ "${RUN_VERBOSE}" = true ]; then   # -v
      h2 "Verify access to GitHub.com using SSH ..."

      # To avoid RESPONSE: PTY allocation request failed on channel 0
      # Ensure that "PermitTTY no" is in ~/.ssh/authorized_keys (on servers to contain id_rsa.pub)
      # See https://bobcares.com/blog/pty-allocation-request-failed-on-channel-0/

      ssh git@github.com  # -vvv  (ssh automatically uses `test-ssh-cert.pub` file)
      # RESPONSE: Hi wilsonmar! You've successfully authenticated, but GitHub does not provide shell access.
             # Connection to github.com closed.
   fi

   exit

fi  # MOVE_SECURELY


if [ "${NODE_INSTALL}" = true ]; then  # -n

# If VAULT is used:

   # h2 "Install -node"
   if [ "${PACKAGE_MANAGER}" == "brew" ]; then # -U
      if ! command -v node ; then
         h2 "Installing node ..."
         brew install node
      else
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "Upgrading node ..."
            brew upgrade node
         fi
      fi
   fi
   note "Node version: $( node --version )"   # v13.8.0
   note "npm version:  $( npm --version )"    # 6.13.7

   h2 "After git clone https://github.com/wesbos/Learn-Node.git ..."
   pwd
   if [ ! -d "starter-files" ]; then   # not found
      fatal  "starter-files folder not found. Aborting..."
      exit 9
   else
      # within repo:
      # cd starter-files 
      cd "stepped-solutions/45 - Finished App"
      h2 "Now at folder path $PWD ..."
      ls -1

      if [ "${CLONE_GITHUB}" = true ]; then   # -clone specified:
   
         h2 "npm install ..."
             npm install   # based on properties.json

         h2 "npm audit fix ..."
             npm audit fix
      fi
   fi

   if [ ! -f "package.json" ]; then   # not found
      fatal  "package.json not found. Aborting..."
      exit 9
   fi


   if [ ! -f "variables.env" ]; then   # not created
      h2 "Downloading variables.env ..."
      # Alternative: Copy from your $HOME/.secrets.env file
      curl -s -O https://raw.githubusercontent.com/wesbos/Learn-Node/master/starter-files/variables.env.sample \
         variables.env
   else
      warning "Reusing variables.env from previous run."
   fi


   # See https://docs.mongodb.com/manual/tutorial/install-mongodb-on-os-x/
   # Instead of https://www.mongodb.com/cloud/atlas/mongodb-google-cloud
   if [ "${PACKAGE_MANAGER}" == "brew" ]; then # -U
      if ! command -v mongo ; then  # command not found, so:
         h2 "Installing mmongodb-compass@4.2 ..."
         brew tap mongodb/brew
         brew install mongodb-compass@4.2
      else  # installed already:
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "Re-installing mongodb-compass@4.2 ..."
            brew untap mongodb/brew && brew tap mongodb/brew
            brew install mongodb-compass@4.2
         fi
      fi
   # elif other operating systems:
   fi
   # Verify whether MongoDB is running, search for mongod in your running processes:
   note "$( mongo --version | grep MongoDB )"    # 3.4.0 in video. MongoDB shell version v4.2.3 

      if [ ! -d "/Applications/mongodb Compass.app" ]; then  # directory not found:
         h2 "Installing cask mongodb-compass ..."
         brew cask install mongodb-compass
            # Downloading https://downloads.mongodb.com/compass/mongodb-compass-1.20.5-darwin-x64.dmg
      else  # installed already:
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "Re-installing cask mongodb-compass ..."
            brew cask uninstall mongodb-compass
         fi
      fi

   h2 "TODO: Configuring MongoDB $MONGO_DB_NAME [4:27] ..."
   replace_1config () {
      file=$1
      var=$2
      new_value=$3
      awk -v var="$var" -v new_val="$new_value" 'BEGIN{FS=OFS="="}match($1, "^\\s*" var "\\s*") {$2=" " new_val}1' "$file"
   }
   # Use the function defined above: https://stackoverflow.com/questions/5955548/how-do-i-use-sed-to-change-my-configuration-files-with-flexible-keys-and-values/5955591#5955591
   # replace_1config "conf" "MAIL_USER" "${GitHub_USER_EMAIL}"  # from 123
   # replace_1config "conf" "MAIL_HOST" "${GitHub_USER_EMAIL}"  # from smpt.mailtrap.io
   # NODE_ENV=development
   # DATABASE=mongodb://user:pass@host.com:port/database
   # MAIL_USER=123
   # MAIL_PASS=123
   # MAIL_HOST=smtp.mailtrap.io
   # MAIL_PORT=2525
   # PORT=7777
   # MAP_KEY=AIzaSyD9ycobB5RiavbXpJBo0Muz2komaqqvGv0
   # SECRET=snickers
   # KEY=sweetsesh


   # shellcheck disable=SC2009  # Consider using pgrep instead of grepping ps output.
   RESPONSE="$( ps aux | grep -v grep | grep mongod )"
         # root 10318   0.0  0.0  4763196   7700 s002  T     4:02PM   0:00.03 sudo mongod
                            note "${RESPONSE}"
              MONGO_PSID=$( echo "${RESPONSE}" | awk '{print $2}' )

   Kill_process(){
      info "Killing process $1 ..."
      sudo kill -2 "$1"
      sleep 2
   }
   if [ -z "${MONGO_PSID}" ]; then  # found
      h2 "Shutting down mongoDB ..."
      # See https://docs.mongodb.com/manual/tutorial/manage-mongodb-processes/
      # DOESN'T WORK: mongod --shutdown
      sudo kill -2 "${MONGO_PSID}"
      #Kill_process "${MONGO_PSID}"  # invoking function above.
         # No response expected.
      sleep 2
   fi
      h2 "Start MongoDB as a background process ..."
      mongod --config /usr/local/etc/mongod.conf --fork
         # ADDITIONAL: --port 27017 --replSet replset --logpath ~/log/mongo.log
         # about to fork child process, waiting until server is ready for connections.
         # forked process: 16698
      # if successful:
         # child process started successfully, parent exiting
      # if not succesful:
         # ERROR: child process failed, exited with error number 48
         # To see additional information in this output, start without the "--fork" option.

      # sudo mongod &
         # RESPONSE EXAMPLE: [1] 10318

   h2 "List last lines for status of mongod process ..." 
   tail -5 /usr/local/var/log/mongodb/mongo.log

fi # if [ "${NODE_INSTALL}


if [ "${RUN_VIRTUALENV}" = true ]; then  # -V  (not the default pipenv)

   h2 "Install -python"
   if [ "${PACKAGE_MANAGER}" == "brew" ]; then # -U
      if ! command -v python3 ; then
         h2 "Installing python3 ..."
         brew install python3
      else
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "Upgrading python3 ..."
            brew upgrade python3
         fi
      fi
   elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
      silent-apt-get-install "python3"
   fi
   note "$( python3 --version )"  # Python 3.7.6
   note "$( pip3 --version )"      # pip 19.3.1 from /Library/Python/2.7/site-packages/pip (python 2.7)


      # h2 "Install virtualenv"  # https://levipy.com/virtualenv-and-virtualenvwrapper-tutorial
      # to create isolated Python environments.
      #pipenv install virtualenvwrapper

      if [ -d "venv" ]; then   # venv folder already there:
         note "venv folder being re-used ..."
      else
         h2 "virtualenv venv ..."
         virtualenv venv
      fi

      h2 "source venv/bin/activate"
      # shellcheck disable=SC1091 # Not following: venv/bin/activate was not specified as input (see shellcheck -x).
      source venv/bin/activate

      # RESPONSE=$( python3 -c "import sys; print(sys.version)" )
      RESPONSE=$( python3 -c "import sys, os; is_conda = os.path.exists(os.path.join(sys.prefix, 'conda-meta'))" )
      h2 "Within (venv) Python3: "
      # echo "${RESPONSE}"
     
   if [ -f "requirements.txt" ]; then
      # Created by command pip freeze > requirements.txt previously.
      # see https://medium.com/@boscacci/why-and-how-to-make-a-requirements-txt-f329c685181e
      # Install the latest versions, which may not be backward-compatible:
      pip3 install -r requirements.txt
   fi

fi   # RUN_VIRTUALENV means Pipenv default


if [ "${USE_PYENV}" = true ]; then  # -py

   h2 "Use Pipenv by default (not overrided by -Virtulenv)"
   # https://www.activestate.com/blog/how-to-build-a-ci-cd-pipeline-for-python/

   # pipenv commands: https://pipenv.kennethreitz.org/en/latest/cli/#cmdoption-pipenv-rm
   note "pipenv in $( pipenv --where )"
      # pipenv in /Users/wilson_mar/projects/python-samples
   # pipenv --venv  # no such option¶
   
   note "$( pipenv --venv || true )"

   #h2 "pipenv lock --clear to flush the pipenv cache"
   #pipenv lock --clear

   # If virtualenvs exists for repo, remove it:
   if [ -n "${WORKON_HOME}" ]; then  # found somethiNg:
      # Unless export PIPENV_VENV_IN_PROJECT=1 is defined in your .bashrc/.zshrc,
      # and export WORKON_HOME=~/.venvs overrides location,
      # pipenv stores virtualenvs globally with the name of the project’s root directory plus the hash of the full path to the project’s root,
      # so several can be generated.
      PIPENV_PATH="${WORKON_HOME}"
   else
      PIPENV_PATH="$HOME/.local/share/virtualenvs/"
   fi
   RESPONSE="$( find "${PIPENV_PATH}" -type d -name *"${GitHub_REPO_NAME}"* )"
   if [ -n "${RESPONSE}" ]; then  # found somethiNg:
      note "${RESPONSE}"
      if [ "${REMOVE_GITHUB_BEFORE}" = true ]; then  # -d 
         pipenv --rm
            # Removing virtualenv (/Users/wilson_mar/.local/share/virtualenvs/bash-8hDxYnPf)…
            # or "No virtualenv has been created for this project yet!  Aborted!

         # pipenv clean  # creates a virtualenv
            # uninistall all dev dependencies and their dependencies:

         pipenv_install   # 
      else
         h2 "TODO: pipenv using current virtualenv ..."
      fi
   else  # no env found, so ...
      h2 "Creating pipenv - no previous virtualenv ..."
      PYTHONPATH='.' pipenv run python main.py    
   fi 

fi    # USE_PYENV


if [ "${RUN_ANACONDA}" = true ]; then  # -A

         if [ "${PACKAGE_MANAGER}" == "brew" ]; then # -U
            if ! command -v anaconda ; then
               h2 "brew cask install anaconda ..."  # miniconda
               brew cask install anaconda
            else
               if [ "${UPDATE_PKGS}" = true ]; then
                  h2 "Upgrading anaconda ..."
                  brew cask upgrade anaconda
               fi
            fi
         elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
            silent-apt-get-install "anaconda"
         fi
         note "$( anaconda version )"  # anaconda Command line client (version 1.7.2)
         #note "$( conda info )"  # VERBOSE
         #note "$( conda list anaconda$ )"
                        
         export PREFIX="/usr/local/anaconda3"
         export   PATH="/usr/local/anaconda3/bin:$PATH"
         note "PATH=$( $PATH )"

         # conda create -n PDSH python=3.7 --file requirements.txt
         # conda create -n tf tensorflow

fi  # RUN_ANACONDA


if [ "${RUN_PYTHON}" = true ]; then  # -s

   # https://docs.python-guide.org/dev/virtualenvs/

   PYTHON_VERSION="$( python3 -V )"   # "Python 3.7.6"
   # TRICK: Remove leading white space after removing first word
   PYTHON_SEMVER=$(sed -e 's/^[[:space:]]*//' <<<"${PYTHON_VERSION//Python/}")

   if [ -z "${MY_FILE}" ]; then  # is empty
      fatal "No program -file specified ..."
      exit 9
   fi

     if [ -z "${MY_FOLDER}" ]; then  # is empty
         note "-Folder not specified for within $PWD ..."
      else
         cd  "${MY_FOLDER}"
      fi

      if [ ! -f "${MY_FILE}" ]; then  # file not found:
         fatal "-file \"${MY_FILE}\" not found ..."
         exit 9
      fi

         h2 "-Good Python ${PYTHON_SEMVER} running ${MY_FILE} ${RUN_PARMS} ..."

         if [ ! -f "Pipfile" ]; then  # file not found:
            note "Pipfile found, run Pipenv ${MY_FILE} ${RUN_PARMS} ..."
            PYTHONPATH='.' pipenv run python "${MY_FILE}" "${RUN_PARMS}"
         fi

            # TRICK: Determine if a Python module was installed:
            RESPONSE="$( python -c 'import pkgutil; print(1 if pkgutil.find_loader("flake8") else 0)' )"
            if [ "${RESPONSE}" = 0 ]; then
               h2 "Installing flake8 PEP8 code formatting scanner ..." 
               # See https://flake8.pycqa.org/en/latest/ and https://www.python.org/dev/peps/pep-0008/
               python3 -m pip install flake8
            fi
               h2 "Running flake8 Pip8 code formatting scanner ..."
               flake8 "${MY_FILE}"

            RESPONSE="$( python -c 'import pkgutil; print(1 if pkgutil.find_loader("flake8") else 0)' )"
            if [ "${RESPONSE}" = 0 ]; then
               h2 "Installing Bandit secure Python coding scanner ..."
               # See https://pypi.org/project/bandit/
               python3 -m pip install bandit
            fi
               h2 "Running Bandit secure Python coding scanner ..."  
               # See https://developer.rackspace.com/blog/getting-started-with-bandit/
               # TRICK: Route console output to a temp folder for display only on error:
               bandit -r "${MY_FILE}" 1>bandit.console.log  2>bandit.err.log
               STATUS=$?
               if ! [ "${STATUS}" == "0" ]; then  # NOT good
                  fatal "Bandit found issues : ${STATUS} "
                  cat bandit.err.log
                  cat bandit.console.log
                  # The above files are removed depending on $REMOVE_GITHUB_AFTER
                  exit 9
               else
                  note "Bandit found ${STATUS} blocking issues."
               fi

            h2 "Running Python file ${MY_FILE} ${RUN_PARMS} ..."
            python3 "${MY_FILE}" "${RUN_PARMS}"
         
fi  # RUN_PYTHON


if [ "${RUN_TENSORFLOW}" = true ]; then 

      if [ -f "$PWD/${MY_FOLDER}/${MY_FILE}" ]; then
         echo "$PWD/${MY_FOLDER}/${MY_FILE}"
         # See https://jupyter-notebook.readthedocs.io/en/latest/notebook.html?highlight=trust#signing-notebooks
         jupyter trust "${MY_FOLDER}/${MY_FILE}"
         # RESPONSE: Signing notebook: section_2/2-3.ipynb
      else
         echo "$PWD/${MY_FOLDER}/${MY_FILE} not found among ..."
         ls   "$PWD/${MY_FOLDER}"
         exit 9
      fi

      # Included in conda/anaconda: jupyterlab & matplotlib

      h2 "installing tensorflow, tensorboard ..."
      # TODO: convert to use pipenv instead?
      pip3 install --upgrade tensorflow   # includes https://pypi.org/project/tensorboard/
      h2 "pip3 show tensorflow"
      pip3 show tensorflow

      # h2 "Install cloudinary Within requirements.txt : "
      # pip install cloudinary
      #if ! command -v jq ; then
      #   h2 "Installing jq ..."
      #   brew install jq
      #else
      #   if [ "${UPDATE_PKGS}" = true ]; then
      #      h2 "Upgrading jq ..."
      #      brew --upgrade --force-reinstall jq 
      #   fi
      #fi
      # /usr/local/bin/jq

   h2 "ipython kernel install --user --name=.venv"
   ipython kernel install --user --name=venv

   h2 "Starting Jupyter with Notebook $MY_FOLDER/$MY_FILE ..."
   jupyter notebook --port 8888 "${MY_FOLDER}/${MY_FILE}" 
      # & for background run
         # jupyter: open http://localhost:8888/tree
      # The Jupyter Notebook is running at:
      # http://localhost:8888/?token=7df8adf321965117234f22973419bb92ecab4e788537b90f

   if [ "$KILL_PROCESSES" = true ]; then  # -K
      ps_kill 'tensorboard'   # bash function defined in this file.
   fi

fi  # if [ "${RUN_TENSORFLOW}"


if [ "${RUN_VIRTUALENV}" = true ]; then  # -V
      h2 "Execute deactivate if the function exists (i.e. has been created by sourcing activate):"
      # per https://stackoverflow.com/a/57342256
      declare -Ff deactivate && deactivate
         #[I 16:03:18.236 NotebookApp] Starting buffering for db5328e3-...
         #[I 16:03:19.266 NotebookApp] Restoring connection for db5328e3-aa66-4bc9-94a1-3cf27e330912:84adb360adce4699bccffc00c7671793
fi


if [ "${RUN_TESTS}" = true ]; then  # -t

   if [ "${PACKAGE_MANAGER}" == "brew" ]; then
      if ! command -v selenium ; then
         h2 "Pip installing selenium ..."
         pip install selenium
      else
         if [ "${UPDATE_PKGS}" = true ]; then
            # selenium in /usr/local/lib/python3.7/site-packages (3.141.0)
            # urllib3 in /usr/local/lib/python3.7/site-packages (from selenium) (1.24.3)
            h2 "Pip upgrading selenium ..."
            pip install -U selenium
         fi
      fi
      # note "$( selenium --version | grep GnuPG )"  # gpg (GnuPG) 2.2.19
   fi

   # https://www.guru99.com/selenium-python.html shows use of Eclipse IDE
   # https://realpython.com/modern-web-automation-with-python-and-selenium/ headless
   # https://www.seleniumeasy.com/python/example-code-using-selenium-webdriver-python Windows chrome

   h2 "Install drivers of Selenium on browsers"
   # First find out what version of Chrome at chrome://settings/help
   # Based on: https://sites.google.com/a/chromium.org/chromedriver/downloads
   # For 80: https://chromedriver.storage.googleapis.com/80.0.3987.106/chromedriver_mac64.zip
   # Unzip creates chromedriver (executable with no extension)
   # Move it to /usr/bin or /usr/local/bin
   # ls: 14713200 Feb 12 16:47 /Users/wilson_mar/Downloads/chromedriver

   # https://developer.apple.com/documentation/webkit/testing_with_webdriver_in_safari
   # Safari:	https://webkit.org/blog/6900/webdriver-support-in-safari-10/
      # /usr/bin/safaridriver is built into macOS.
      # Run: safaridriver --enable  (needs password)

   # Firefox:	https://github.com/mozilla/geckodriver/releases
      # geckodriver-v0.26.0-macos.tar expands to geckodriver
   
   # reports are produced by TestNG, a plug-in to Selenium.

fi # if [ "${RUN_TESTS}"


if [ "${RUBY_INSTALL}" = true ]; then  # -i

   # https://websiteforstudents.com/install-refinery-cms-ruby-on-rails-on-ubuntu-16-04-18-04-18-10/

   if [ "${PACKAGE_MANAGER}" == "brew" ]; then

      if ! command -v gnupg2 ; then
         h2 "Installing gnupg2 ..."
         brew install gnupg2
      else
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "Upgrading gnupg2 ..."
            brew upgrade gnupg2
         fi
      fi
      note "$( gpg --version | grep GnuPG )"  # gpg (GnuPG) 2.2.19

      # download and install the mpapis public key with GPG:
      #curl -sSL https://rvm.io/mpapis.asc | gpg --import -
         # (Michael Papis (mpapis) is the creator of RVM, and his public key is used to validate RVM downloads:
         # gpg-connect-agent --dirmngr 'keyserver --hosttable'
      #gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
         # FIX: gpg: keyserver receive failed: No route to host

      if ! command -v imagemagick ; then
         h2 "Installing imagemagick ..."
         brew install imagemagick
      else
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "Upgrading imagemagick ..."
            brew upgrade imagemagick
         fi
      fi

   elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then

      sudo apt-get update

      h2 "Use apt instead of apt-get since Ubuntu 16.04 (from Linux Mint)"
      sudo apt install curl git
      note "$( git --version --build-options )"
         # git version 2.20.1 (Apple Git-117), cpu: x86_64, no commit associated with this build
         # sizeof-long: 8, sizeof-size_t: 8

      h2 "apt install imagemagick"
      sudo apt install imagemagick

      h2 "sudo apt autoremove"
      sudo apt autoremove

      h2 "Install NodeJs to run Ruby"
      curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
      silent-apt-get-install "nodejs"

      h2 "Add Yarn repositories and keys (8.x deprecated) for apt-get:"
      curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
         # response: OK
      echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
      silent-apt-get-install "yarn" 

      h2 "Install Ruby dependencies "
      silent-apt-get-install "rbenv"   # instead of git clone https://github.com/rbenv/rbenv.git ~/.rbenv
         # Extracting templates from packages: 100%
      silent-apt-get-install "autoconf"
      silent-apt-get-install "bison"
      silent-apt-get-install "build-essential"
      silent-apt-get-install "libssl-dev"
      silent-apt-get-install "libyaml-dev"
      silent-apt-get-install "zlib1g-dev"
      silent-apt-get-install "libncurses5-dev"
      silent-apt-get-install "libffi-dev"
         # E: Unable to locate package autoconf bison
      silent-apt-get-install "libreadline-dev"    # instead of libreadline6-dev 
      silent-apt-get-install "libgdbm-dev"    # libgdbm3  # (not found)

      silent-apt-get-install "libpq-dev"
      silent-apt-get-install "libxml2-dev"
      silent-apt-get-install "libxslt1-dev"
      silent-apt-get-install "libcurl4-openssl-dev"
      
      h2 "Install SQLite3 ..."
      silent-apt-get-install "libsqlite3-dev"
      silent-apt-get-install "sqlite3"

      h2 "Install MySQL Server"
      silent-apt-get-install "mysql-client"
      silent-apt-get-install "mysql-server"
      silent-apt-get-install "libmysqlclient-dev"  # unable to locate

      #h2 "Install PostgreSQL ..."
      #silent-apt-get-install "postgres"

   elif [ "${PACKAGE_MANAGER}" == "yum" ]; then
      # TODO: More For Redhat distro:
      sudo yum install ruby-devel
   elif [ "${PACKAGE_MANAGER}" == "zypper" ]; then
      # TODO: More for [open]SuSE:
      sudo zypper install ruby-devel
   fi

      note "$( nodejs --version )"
      note "$( yarn --version )"
      note "$( sqlite3 --version )"


   cd ~/
   h2 "Now at path $PWD ..."

   h2 "git clone ruby-build.git to use the rbenv install command"
   FOLDER_PATH="$HOME/.rbenv/plugins/ruby-build"
   if [   -d "${FOLDER_PATH}" ]; then  # directory found, so remove it first.
      note "Deleting ${FOLDER_PATH} ..."
      rm -rf "${FOLDER_PATH}"
   fi
      git clone https://github.com/rbenv/ruby-build.git  "${FOLDER_PATH}"
         if grep -q ".rbenv/plugins/ruby-build/bin" "${BASHFILE}" ; then
            note "rbenv/plugins/ already in ${BASHFILE}"
         else
            info "Appending rbenv/plugins in ${BASHFILE}"
            echo "export PATH=\"$HOME/.rbenv/plugins/ruby-build/bin:$PATH\" " >>"${BASHFILE}"
            source "${BASHFILE}"
         fi
   
   if ! command -v rbenv ; then
      fatal "rbenv not found. Aborting for script fix ..."
      exit 1
   fi

   h2 "rbenv init"
            if grep -q "rbenv init " "${BASHFILE}" ; then
               note "rbenv init  already in ${BASHFILE}"
            else
               info "Appending rbenv init - in ${BASHFILE} "
               # shellcheck disable=SC2016 # Expressions don't expand in single quotes, use double quotes for that.
               echo "eval \"$( rbenv init - )\" " >>"${BASHFILE}"
               source "${BASHFILE}"
            fi
            # This results in display of rbenv().

   # Manually lookup latest stable release in https://www.ruby-lang.org/en/downloads/
   RUBY_RELEASE="2.6.5"  # 2.7.0"
   RUBY_VERSION="2.6"
      # To avoid rbenv: version `2.7.0' not installed

   h2 "Install Ruby $RUBY_RELEASE using rbenv ..."
   # Check if the particular Ruby version is already installed by rbenv
   RUBY_RELEASE_RESPONSE="$( rbenv install -l | grep $RUBY_RELEASE )"
   if [ -z "$RUBY_RELEASE_RESPONSE" ]; then  # not found:
      rbenv install "${RUBY_RELEASE}"
      # Downloading ...
   fi

   h2 "rbenv global"
   rbenv global "${RUBY_RELEASE}"   # insted of -l (latest)

   h2 "Verify ruby version"
   ruby -v

   h2 "To avoid Gem:ConfigMap deprecated in gem 1.8.x"
   # From https://github.com/rapid7/metasploit-framework/issues/12763
   gem uninstall #etc
   # This didn't fix: https://ryenus.tumblr.com/post/5450167670/eliminate-rubygems-deprecation-warnings
   # ruby -e "`gem -v 2>&1 | grep called | sed -r -e 's#^.*specifications/##' -e 's/-[0-9].*$//'`.split.each {|x| `gem pristine #{x} -- --build-arg`}"
   
   h2 "gem update --system"
   # Based on https://github.com/rubygems/rubygems/issues/3068
   # to get rid of the warnings by downgrading to the latest RubyGems that doesn't have the deprecation warning:
   sudo gem update --system   # 3.0.6
   
   gem --version
   
   h2 "create .gemrc"  # https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-with-rbenv-on-ubuntu-16-04
   if [ ! -f "$HOME/.gemrc" ]; then   # file NOT found, so create it:
      echo "gem: --no-document" > ~/.gemrc
   else
      if grep -q "gem: --no-document" "$HOME/.gemrc" ; then   # found in file:
         note "gem: --no-document already in $HOME/.gemrc "
      else
         info "Adding gem --no-document in $HOME/.gemrc "
         echo "gem: --no-document" >> "$HOME/.gemrc"
      fi
   fi

   h2 "gem install bundler"  # https://bundler.io/v1.12/rationale.html
   sudo gem install bundler   # 1.17.3 to 2.14?
   note "$( bundler --version )"  # Current Bundler version: bundler (2.1.4)

   # To avoid Ubuntu rails install ERROR: Failed to build gem native extension.
   # h2 "gem install ruby-dev"  # https://stackoverflow.com/questions/22544754/failed-to-build-gem-native-extension-installing-compass
   h2 "Install ruby${RUBY_VERSION}-dev for Ruby Development Headers native extensions ..."
   silent-apt-get-install ruby-dev   # "ruby${RUBY_VERSION}-dev"
        # apt-get install ruby-dev

   h2 "gem install rails"  # https://gorails.com/setup/ubuntu/16.04
   sudo gem install rails    # latest at https://rubygems.org/gems/rails/versions
   if ! command -v rails ; then
      fatal "rails not found. Aborting for script fix ..."
      exit 1
   fi
   note "$( rails --version | grep "Rails" )"  # Rails 3.2.22.5
      # See https://rubyonrails.org/
      # 6.0.2.1 - December 18, 2019 (6.5 KB)

   h2 "rbenv rehash to make the rails executable available:"  # https://github.com/rbenv/rbenv
   sudo rbenv rehash

   h2 "gem install rdoc (Ruby doc)"
   sudo gem install rdoc

   h2 "gem install execjs"
   sudo gem install execjs

   h2 "gem install refinerycms"
   sudo gem install refinerycms
       # /usr/lib/ruby/include

   h2 "Build refinery app"
   refinerycms "${APPNAME}"
   # TODO: pushd here instead of cd?
      cd "${APPNAME}"   

   # TODO: Add RoR app resources from GitHub  (gem file)
   # TODO: Internationalize Refinery https://www.refinerycms.com/guides/translate-refinery
   # create branch for a language (nl=dutch):
          # git checkout -b i18n_nl
   # Issue rake task to get a list of missing translations for a given locale:
   # Add the keys
   # Run the Refinery tests to be sure you didn't break something, and that your YAML is valid.
      # bin/rake spec


   h2 "bundle install based on gem file ..."
   bundle install

   h2 "Starting rails server at ${APPNAME} ..."
   cd "${APPNAME}"
   note "Now at $PWD ..."
   rails server

   h2 "Opening website ..."
      curl -s -I -X POST http://localhost:3000/refinery
      curl -s       POST http://localhost:3000/ | head -n 10  # first 10 lines

   # TODO: Use Selenium to manually logon to the backend using the admin address and password…

   exit

fi # if [ "${RUBY_INSTALL}" = true ]; then  # -i



if [ "${RUN_EGGPLANT}" = true ]; then  # -O

   # As seen at https://www.youtube.com/watch?v=B64_4r0vGkA May 28, 2020

   # See http://docs.eggplantsoftware.com/ePF/gettingstarted/epf-getting-started-eggplant-functional.htm
   if [ "${PACKAGE_MANAGER}" == "brew" ]; then # -U
      if [ ! -d "/Applications/eggplant.app" ]; then  # directory not found:
         h2 "brew cask install eggplant ..."
         brew cask install eggplant
      else  # installed already:
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "Re-installing cask eggplant ..."
            brew cask uninstall eggplant
         fi
      fi
   fi  #  PACKAGE_MANAGER}" == "brew" 

   if [ "${OPEN_APP}" = true ]; then  # -W
      if [ "${OS_TYPE}" == "macOS" ]; then  # it's on a Mac:
         sleep 3
         open "/Applications/eggplant.app"
         # TODO: Configure floating license server 10.190.70.30
      fi
   fi
   # Configure floating license on local & SUT on same network 10.190.70.30
   # Thank you to Ritdhwaj Singh Chandel


   if [ "${PACKAGE_MANAGER}" == "brew" ]; then # -U
      # Alternately, https://www.realvnc.com/en/connect/download/vnc/macos/
      if [ ! -d "/Applications/RealVNC/VNC Server.app" ]; then  # directory not found:
         h2 "brew cask install vnc-server ..."
             brew cask install vnc-server
             # Requires password
             # pop-up "vncagent" and "vncviwer" would like to control this computer using accessibility features
      else
         if [ "${UPDATE_PKGS}" = true ]; then
            h2 "brew cask upgrade vnc-server ..."
                brew cask upgrade vnc-server
         fi
      fi
   fi   # PACKAGE_MANAGER


   if [ "$OPEN_APP" = true ]; then  # -o
      if [ "$OS_TYPE" == "macOS" ]; then  # it's on a Mac:
         open "/Applications/RealVNC/VNC Server.app"
         # TODO: Automate configure app to input email, home subscription type, etc.
            # In Mac: ~/.vnc/config.d/vncserver
            # See https://help.realvnc.com/hc/en-us/articles/360002253878-Configuring-VNC-Connect-Using-Parameters
         # Uncheck System Preferences > Energy Saver, Prevent computer from sleeping automatically when the display is off
            # See https://help.realvnc.com/hc/en-us/articles/360003474692
         # Understanding VNC Server Modes: https://help.realvnc.com/hc/en-us/articles/360002253238
      fi
   fi


   if [ ! -f "docker-compose.yml" ]; then
      h2 "Download docker-compose.yml ..."
      curl -s -O https://raw.GitHubusercontent.com/wilsonmar/DevSecOps/master/eggplant/docker-compose.yml
      # ls -al docker-compose.yml
      # Valid yaml according to http://www.yamllint.com
      # referencing https://registry.hub.docker.com/search?q=selenium&type=image
   fi

   # Reference: http://docs.eggplantsoftware.com/eggplant-documentation-home.htm

fi    # RUN_EGGPLANT



if [ "${USE_DOCKER}" = true ]; then   # -k

   if [ "${DOWNLOAD_INSTALL}" = true ]; then  # -I & -U

      h2 "Install Docker and docker-compose:"

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

          if ! command -v curl ; then
             h2 "Installing Curl ..."
             brew install curl wget tree
          else
             if [ "${UPDATE_PKGS}" = true ]; then
                h2 "Upgrading Curl ..."
                brew upgrade curl wget tree
             fi
          fi

       elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then

         if ! command -v docker ; then
            h2 "Installing docker using apt-get ..."
            silent-apt-get-install "docker"
         else
            if [ "${UPDATE_PKGS}" = true ]; then
               h2 "Upgrading docker ..."
               silent-apt-get-install "docker"
            fi
         fi

         if ! command -v docker-compose ; then
            h2 "Installing docker-compose using apt-get ..."
            silent-apt-get-install "docker-compose"
         else
            if [ "${UPDATE_PKGS}" = true ]; then
               h2 "Upgrading docker-compose ..."
               silent-apt-get-install "docker-compose"
            fi
         fi

      elif [ "${PACKAGE_MANAGER}" == "yum" ]; then
      
         if ! command -v docker ; then
            h2 "Installing docker using yum ..."
            sudo yum install docker
         else
            if [ "${UPDATE_PKGS}" = true ]; then
               h2 "Upgrading docker ..."
               sudo yum install docker
            fi
         fi

         if ! command -v docker-compose ; then
            h2 "Installing docker-compose using yum ..."
            yum install docker-compose
         else
            if [ "${UPDATE_PKGS}" = true ]; then
               h2 "Upgrading docker-compose ..."
               yum install docker-compose
            fi
         fi

      fi # brew

      note "$( docker --version )"
         # Docker version 19.03.5, build 633a0ea
      note "$( docker-compose --version )"
         # docker-compose version 1.24.1, build 4667896b

   fi  # DOWNLOAD_INSTALL

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
   note "$rep"
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


   if [ "${BUILD_DOCKER_IMAGE}" = true ]; then   # -b
      h2 "Building docker images ..."
   fi    # BUILD_DOCKER_IMAGE


   h2 "Remove dangling docker images ..."
   docker rmi -f "$( docker images -qf dangling=true )"
   #   if [ -z `docker ps -q --no-trunc | grep $(docker-compose ps -q "$DOCKER_WEB_SVC_NAME")` ]; then
      # --no-trunc flag because docker ps shows short version of IDs by default.

   #.   note "If $DOCKER_WEB_SVC_NAME is not running, so run it..."

   if [ "${RUN_ACTUAL}" = true ]; then  # -a for actual usage

      if [ "${RUN_EGGPLANT}" = true ]; then  # -O

         h2 "docker run selenium-hub at hub.docker.com ..."
         docker run -d -p 4444:4444 --name selenium-hub selenium/hub

         #docker run -d --link selenium-hub:hub -v /dev/shm:/dev/shm selenium/node-chrome
         #docker run -d --link selenium-hub:hub -v /dev/shm:/dev/shm selenium/node-firefox

         h2 "docker-compose selenium container images at hub.docker.com ..."
         # docker-compose -f "docker-compose.yml" up -d --build
         # FIXME:
         # ERROR: yaml.scanner.ScannerError: mapping values are not allowed here
         # in "./docker-compose.yml", line 9, column 25
      
      else

         # https://docs.docker.com/compose/reference/up/
         docker-compose up --detach --build
         # --build specifies rebuild of pip install image for changes in requirements.txt
         # NOTE: detach with ^P^Q.
         # Creating network "snakeeyes_default" with the default driver
         # Creating volume "snakeeyes_redis" with default driver
         # Status: Downloaded newer image for node:12.14.0-buster-slim

      # worker_1   | [2020-01-17 04:59:42,036: INFO/Beat] beat: Starting...
      fi # if [ "${RUN_EGGPLANT}" = true ]; then  # -O

   fi   # RUN_ACTUAL

   h2 "docker container ls ..."
   docker container ls
         # CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS                    PORTS                    NAMES
         # 3ee3e7ef6d75        snakeeyes_web        "/app/docker-entrypo…"   35 minutes ago      Up 35 minutes (healthy)   0.0.0.0:8000->8000/tcp   snakeeyes_web_1
         # fb64e7c95865        snakeeyes_worker     "/app/docker-entrypo…"   35 minutes ago      Up 35 minutes             8000/tcp                 snakeeyes_worker_1
         # bc68e7cb0f41        snakeeyes_webpack    "docker-entrypoint.s…"   About an hour ago   Up 35 minutes                                      snakeeyes_webpack_1
         # 52df7a11b666        redis:5.0.7-buster   "docker-entrypoint.s…"   About an hour ago   Up 35 minutes             6379/tcp                 snakeeyes_redis_1
         # 7b8aba1d860a        postgres             "docker-entrypoint.s…"   7 days ago          Up 7 days                 0.0.0.0:5432->5432/tcp   snoodle-postgres

   # TODO: Add run in local Kubernetes.

fi  # if [ "${USE_DOCKER}


if [ "${OPEN_APP}" = true ]; then  # -W
   if [ "${OS_TYPE}" == "macOS" ]; then  # it's on a Mac:
      sleep 3
      open "http://localhost:${APP1_PORT}"
   fi

   curl -s -I -X POST http://localhost:8000/ 
   curl -s       POST http://localhost:8000/ | head -n 10  # first 10 lines
fi


# if [ "${RUN_TESTS}" = true 

   # TODO: Run tests

# fi  # if [ "${RUN_TESTS}" = true 


if [ "$DELETE_CONTAINER_AFTER" = true ]; then  # -D

   if [ "${RUN_EGGPLANT}" = true ]; then  # -O
      h2 "docker-compose down containers ..."
      docker-compose -f "docker-compose.yml" down
   else
      # https://www.thegeekdiary.com/how-to-list-start-stop-delete-docker-containers/
      h2 "Deleting docker-compose active containers ..."
      CONTAINERS_RUNNING="$( docker ps -a -q )"
      note "Active containers: $CONTAINERS_RUNNING"

      note "Stopping containers:"
      docker stop "$( docker ps -a -q )"

      note "Removing containers:"
      docker rm -v "$( docker ps -a -q )"
   fi # if [ "${RUN_EGGPLANT}" = true ]; then  # -O
fi


if [ "$KILL_PROCESSES" = true ]; then  # -K
   if [ "${NODE_INSTALL}" = true ]; then  # -n
      if [ -n "${MONGO_PSID}" ]; then  # not found
         h2 "Kill_process ${MONGO_PSID} ..."
         Kill_process "${MONGO_PSID}"  # invoking function above.
      fi
   fi 
fi


if [ "$REMOVE_GITHUB_AFTER" = true ]; then  # -C
   h2 "Delete cloned GitHub at end ..."
   Delete_GitHub_clone    # defined above in this file.
   
   h2 "Remove files in ~/temp folder ..."
   rm bandit.console.log
   rm bandit.err.log
fi


if [ "$REMOVE_DOCKER_IMAGES" = true ]; then  # -M

   docker system df
   
   DOCKER_IMAGES="$( docker images -a -q )"
   if [ -n "$DOCKER_IMAGES" ]; then  # variable is NOT empty
      h2 "Removing all Docker images ..."
      docker rmi "$( docker images -a -q )"

      h2 "docker image prune -all ..."  # https://docs.docker.com/config/pruning/
      y | docker image prune -a
         # all stopped containers
         # all volumes not used by at least one container
         # all networks not used by at least one container
         # all images without at least one container associated to
      # y | docker system prune
   fi

   h2 "docker images -a ..."
   note "$( docker images -a )"

fi

# EOF
