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

SCRIPT_VERSION="v0.65"
clear  # screen (but not history)
echo "================================================ $SCRIPT_VERSION "

# Capture starting timestamp and display no matter how it ends:
EPOCH_START="$( date -u +%s )"  # such as 1572634619
LOG_DATETIME=$( date +%Y-%m-%dT%H:%M:%S%z)-$((1 + RANDOM % 1000))


# Ensure run variables are based on arguments or defaults ..."
args_prompt() {
   echo "USAGE EXAMPLE during testing:"
   echo "./sample.sh -v -g \"abcdef...89\" -p \"cp100-1094\"  # Google API call"
   echo "./sample.sh -v -n -a  # NodeJs app with MongoDB"
   echo "./sample.sh -v -i -o  # Ruby app"   
   echo "./sample.sh -v -I -U -c -s -r -a -w  # Python app"
   echo "./sample.sh -v -V -c -T -F \"section_2\" -f \"2-1.ipynb\" -K  # Jupyter anaconda Tensorflow in Venv"
   echo "USAGE EXAMPLE after testing:"
   echo "./sample.sh -v -D -M -C"
   echo "OPTIONS:"
   echo "   -E           to set -e to NOT stop on error"
   echo "   -X           to set -x to trace command lines"
#   echo "   -x           to set sudoers -e to stop on error"
   echo "   -H           install -Hashicorp Vault secret manager"
   echo "   -v           to run -verbose (list space use and each image to console)"
   echo "   -V           to run within VirtualEnv"
   echo "   -g \"abcdef...89\" -gcloud API credentials for calls"
   echo "   -i           -install Ruby and Refinery"
   echo "   -j            install -JavaScript (NodeJs) app with MongoDB"
   echo "   -y            install Python in Virtualenv"
   echo "   -I           -Install brew, docker, docker-compose"
   echo "   -U           -Upgrade packages"

   echo "   -c           -clone from GitHub"
   echo "   -F \"abc\"     -Folder for working"
   echo "   -p \"cp100\"     -project in cloud"

   echo "   -s \"~/.secrets.sh\"  -secrets file (in your user home folder)"
#  echo "   -S           -Store image built in DockerHub"
   echo "   -n \"John Doe\"            GitHub user -name"
   echo "   -e \"john_doe@gmail.com\"  GitHub user -email"
   echo "   -r           start Docker before -run"
   echo "   -b           -build Docker image"
   echo "   -a           -actually run docker-compose"

   echo "   -A           run in -Anaconda "
   echo "   -T           run -Tensorflow"
   echo "   -t           run -tests"

   echo "   -w           open/view -web page in default browser"
   echo "   -D           -Delete files after run (to save disk space)"
   echo "   -M           remove Docker iMages pulled from DockerHub"
   echo "   -C           remove -Cloned files after run (to save disk space)"
   echo "   -K           stop processes at end of run (to save CPU)"
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
   SET_EXIT=true                # -E
   SET_TRACE=false              # -x
   RUN_VERBOSE=false            # -v
   RUN_TESTS=false              # -t
   RUN_VIRTUALENV=false         # -V
   RUN_ANACONDA=false           # -A
   USE_GOOGLE_CLOUD=false       # -g
       GOOGLE_API_KEY=""  # manually copied from APIs & services > Credentials
   PROJECT_NAME=""              # -p                 
   PYTHON_INSTALL=false         # 
   USE_VAULT=false              # -H
   RUBY_INSTALL=false           # -i
   NODE_INSTALL=false           # -n
      MONGO_DB_NAME=""
   SECRETS_FILE="variables.env.sample"
      MY_FOLDER="section_2"
      MY_FILE="1-2.ipynb"
     #MY_FILE="2-3.ipynb"
   UPDATE_PKGS=false            # -U
   RESTART_DOCKER=false         # -r
   BUILD_DOCKER_IMAGE=false     # -b
   RUN_ACTUAL=false             # -a  (dry run is default)
   DOWNLOAD_INSTALL=false       # -I
   RUN_DELETE_AFTER=false       # -D
   RUN_TENSORFLOW               # -T
   RUN_OPEN_BROWSER=false       # -w
   CLONE_GITHUB=false           # -c
   REMOVE_GITHUB_AFTER=false    # -R
   USE_SECRETS_FILE=false       # -s
   REMOVE_DOCKER_IMAGES=false   # -M
   KILL_PROCESSES=false         # -K

SECRETS_FILEPATH="$HOME/.secrets.sh"  # -S
PROJECT_FOLDER_PATH="$HOME/projects"  # -P

GitHub_USER_NAME="Wilson Mar"                  # -n
GitHub_USER_EMAIL="wilson_mar@gmail.com"       # -e
GitHub_REPO_NAME=""

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
      export RUN_DELETE_AFTER=true
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
    -p*)
      shift
             PROJECT_NAME=$( echo "$1" | sed -e 's/^[^=]*=//g' )
      export PROJECT_NAME
      shift
      ;;
    -K)
      export KILL_PROCESSES=true
      shift
      ;;
    -r)
      export RESTART_DOCKER=true
      shift
      ;;
    -s*)
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
      shift
      ;;
    -v)
      export RUN_VERBOSE=true
      shift
      ;;
    -U)
      export UPDATE_PKGS=true
      shift
      ;;
    -V)
      export RUN_VIRTUALENV=true
      GitHub_REPO_URL="https://github.com/PacktPublishing/Hands-On-Machine-Learning-with-Scikit-Learn-and-TensorFlow-2.0.git"
      GitHub_REPO_NAME="scikit"
      APPNAME="scikit"
      #MY_FOLDER="section_2" # or ="section_3"
      shift
      ;;
    -w)
      export RUN_OPEN_BROWSER=true
      shift
      ;;
    -x)
      export SET_TRACE=true
      shift
      ;;
    -X)
      export SET_XTRACE=true
      shift
      ;;
    -y)
      export PYTHON_INSTALL=true
      GitHub_REPO_URL="https://github.com/nickjj/build-a-saas-app-with-flask.git"
      GitHub_REPO_NAME="rockstar"
      APPNAME="rockstar"
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
   printf "\n${bold}${cyan} ${reset} ${cyan}%s${reset}" "$(echo "$@" | sed '/./,$!d')\n"
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
   h2  "BASHFILE=~/.bash_profile ..."
   BASHFILE="$HOME/.bash_profile"  # on Macs
else
   h2  "BASHFILE=~/.bashrc ..."
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

IFS=$'\n\t'  #  Internal Field Separator for word splitting is line or tab, not spaces.

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
# note "$( ls )"


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


# TODO: Capture password manual input once for multiple shares 
# (without saving password like expect command) https://www.linuxcloudvps.com/blog/how-to-automate-shell-scripts-with-expect-command/
   # From https://askubuntu.com/a/711591
#   read -p "Password: " -s szPassword
#   printf "%s\n" "$szPassword" | sudo --stdin mount \
#      -t cifs //192.168.1.1/home /media/$USER/home \
#      -o username=$USER,password="$szPassword"


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
   note "Now at $PWD HOME=$HOME"

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

   h2 "Install package managers ..."

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

   fi # brew

fi # if [ "${DOWNLOAD_INSTALL}" = true ]; then 



if [ "${USE_GOOGLE_CLOUD}" = true ]; then   # -g

   h2 "Create new repository using gcloud & git commands:"
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
      git clone "${GitHub_REPO_URL}" "$GitHub_REPO_NAME"
      cd "$GitHub_REPO_NAME"
      note "At $PWD"
}
if [ "${CLONE_GITHUB}" = true ]; then   # -clone specified:
   h2 "-clone requested for $GitHub_REPO_URL $GitHub_REPO_NAME ..."
   PROJECT_FOLDER_FULL_PATH="${PROJECT_FOLDER_PATH}/${GitHub_REPO_NAME}"
   if [ -d "${PROJECT_FOLDER_FULL_PATH:?}" ]; then  # path available.
      rm -rf "$GitHub_REPO_NAME" 
      Delete_GitHub_clone    # defined above in this file.
   fi

      Clone_GitHub_repo      # defined above in this file.
      # curl -s -O https://raw.GitHubusercontent.com/wilsonmar/build-a-saas-app-with-flask/master/sample.sh
      # git remote add upstream https://github.com/nickjj/build-a-saas-app-with-flask
      # git pull upstream master

else   # do not -clone
   #if [ -d "${GitHub_REPO_NAME:?}" ]; then  # path available.
   if [ -d "${GitHub_REPO_NAME}" ]; then  # path available.
      h2 "Re-using repo $GitHub_REPO_URL $GitHub_REPO_NAME ..."
      cd "$GitHub_REPO_NAME"
   else
      h2 "Cloning repo $GitHub_REPO_URL $GitHub_REPO_NAME ..."
      git clone "${GitHub_REPO_URL}" "$GitHub_REPO_NAME"
      cd "$GitHub_REPO_NAME"
   fi
fi
note "Now at $PWD ..."


### Get secrets from $HOME/.secrets.sample.sh file:
Input_GitHub_User_Info(){
      # https://www.shellcheck.net/wiki/SC2162: read without -r will mangle backslashes.
      read -r -p "Enter your GitHub user name [John Doe]: " GitHub_USER_NAME
      GitHub_USER_NAME=${GitHub_USER_NAME:-"John Doe"}

      read -r -p "Enter your GitHub user email [john_doe@gmail.com]: " GitHub_USER_EMAIL
      GitHub_USER_EMAIL=${GitHub_USER_EMAIL:-"johb_doe@gmail.com"}
}
if [ "${USE_SECRETS_FILE}" = true ]; then  # -s
   if [ ! -f "$SECRETS_FILEPATH" ]; then   # file NOT found, then copy from github:
      warning "File not found in $SECRETS_FILEPATH. Downloading file .secrets.sample.sh ... "
      curl -s -O https://raw.GitHubusercontent.com/wilsonmar/DevSecOps/master/.secrets.sample.sh
      warning "Moving downloaded file to $HOME/.secrets.sh ... "
      mv .secrets.sample.sh  .secrets.sh
      fatal "Please edit file $HOME/.secrets.sh and run again ..."
      exit 1
   else  # file found:
      h2 "Using settings in $SECRETS_FILEPATH "
      ls -al "$SECRETS_FILEPATH"
      chmod +x "$SECRETS_FILEPATH"
      source   "$SECRETS_FILEPATH"  # run file containing variable definitions.
      note "GitHub_USER_NAME=\"$GitHub_USER_NAME\" read from file $SECRETS_FILEPATH"
   fi
else  # flag not to use file, then manually input:
   warning "Using default GitHub user info ..."
   # Input_GitHub_User_Info  # function defined above.
fi  # USE_SECRETS_FILE


if [ -z "$GitHub_USER_EMAIL" ]; then   # variable is blank
   Input_GitHub_User_Info  # function defined above.
else
   note "Using -u \"$GitHub_USER_NAME\" -e \"$GitHub_USER_EMAIL\" \n ..."
   # since this is hard coded as "John Doe" above
fi


if [ "${USE_SECRETS_FILE}" = true ]; then  # -s

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
      fi

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
   elif [ "${USE_GOOGLE_CLOUD}" = true ]; then   # -g
      # assume setup done by https://wilsonmar.github.io/gcp
      # See https://cloud.google.com/solutions/secrets-management
      # https://github.com/GoogleCloudPlatform/berglas is being migrated to Google Secrets Manager.
      # See https://github.com/sethvargo/secrets-in-serverless/tree/master/gcs to encrypt secrets on Google Cloud Storage accessed inside a serverless Cloud Function.
      # using gcloud beta secrets create "my-secret" --replication-policy "automatic" --data-file "/tmp/my-secret.txt"
      h2 "Retrieve secret version from Google Cloud Secret Manager ..."
      gcloud beta secrets versions access "latest" --secret "my-secret"
         # A secret version contains the actual contents of a secret. "latest" is the VERSION_ID      
   #elif [ "${USE_AWS_CLOUD}" = true ]; then   # -w
      # brew cask install aws-vault
      # See https://www.davehall.com.au/tags/bash
   #elif [ "${USE_AZURE_CLOUD}" = true ]; then   # -z
      # See https://docs.microsoft.com/en-us/cli/azure/keyvault/secret?view=azure-cli-latest
      # brew cask install azure-vault
   else
      # See https://learn.hashicorp.com/vault/getting-started/install  # server
      # NOTE: vault-cli is a Subversion-like utility to work with Jackrabbit FileVault (not Hashicorp Vault)
      if [ "${PACKAGE_MANAGER}" == "brew" ]; then
         if ! command -v vault >/dev/null; then  # command not found, so:
            h2 "Brew installing vault ..."
            brew install vault
            # vault -autocomplete-install
            # exec $SHELL
         else  # installed already:
            if [ "${UPDATE_PKGS}" = true ]; then
               h2 "Brew upgrading vault ..."
               brew upgrade vault
               # vault -autocomplete-install
               # exec $SHELL
            fi
         fi
         note "$( vault --version )"  # Vault v1.3.2
         # See https://github.com/sethvargo/secrets-in-serverless using kv or aws (iam) secrets engine.

      elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
         silent-apt-get-install "vault"
      elif [ "${PACKAGE_MANAGER}" == "yum" ]; then    # For Redhat distro:
         sudo yum install vault      # please test
         exit 9
      elif [ "${PACKAGE_MANAGER}" == "zypper" ]; then   # for [open]SuSE:
         sudo zypper install vault   # please test
         exit 9
      fi
   fi

   # https://learn.hashicorp.com/vault/secrets-management/sm-versioned-kv
   # https://www.vaultproject.io/api/secret/kv/kv-v2.html


   # If git user not already configured ...
      # note "$( git config --list )"
   RESPONSE="$( git config --get user.email )"
   if [ -n "${RESPONSE}" ]; then  # not found
      if [[ $RESPONSE == "$GitHub_USER_EMAIL" ]]; then  # already defined:
         info "GitHub_USER_EMAIL being configured ..."
      else
         git config --global user.email "$GitHub_USER_EMAIL"
      fi
      info "$( git config --get user.email )"
   fi

   RESPONSE="$( git config --get user.name )"
   if [ -n "${RESPONSE}" ]; then  # not found
      if [[ $RESPONSE == "$GitHub_USER_NAME" ]]; then  # already defined:
         info "GitHub_USER_EMAIL being configured ..."
      else
         git config --global user.name  "$GitHub_USER_NAME"
      fi
      info "$( git config --get user.email )"
   fi


   if [ ! -f ".env" ]; then
      cp .env.example  .env
   else
      warning "no .env file"
   fi

   if [ ! -f "docker-compose.override.yml" ]; then
      cp docker-compose.override.example.yml  docker-compose.override.yml
   else
      warning "no .yml file"
   fi
fi

# echo "wow"; exit  #debugging unexpected end of file



if [ "${USE_GOOGLE_CLOUD}" = true ]; then   # -g

   # https://google.qwiklabs.com/games/759/labs/2373
   h2 "GCP Speech-to-Text API"  # https://cloud.google.com/speech/reference/rest/v1/RecognitionConfig
   # usage limits: https://cloud.google.com/speech-to-text/quotas
   curl -O -s "https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/gcp/gcp-speech-to-text/request.json"
   cat request.json
   # Listen to it at: https://storage.cloud.google.com/speech-demo/brooklyn.wav
   
   curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
      "https://speech.googleapis.com/v1/speech:recognize?key=${GOOGLE_API_KEY}" > result.json
   cat result.json

exit

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


if [ "${NODE_INSTALL}" = true ]; then  # -n

   h2 "Install -node"
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

fi # if [ "${NODE_INSTALL}" = true ]; then 


if [ "${RUN_VIRTUALENV}" = true ]; then  # -V

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
   note "$( pip --version )"      # pip 19.3.1 from /Library/Python/2.7/site-packages/pip (python 2.7)


      # h2 "Install virtualenv"  # https://levipy.com/virtualenv-and-virtualenvwrapper-tutorial
      # to create isolated Python environments.
      #pip3 install virtualenvwrapper

      if [ -d "venv" ]; then   # venv folder already there:
         note "venv folder found."
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
     
   # from pip freeze > requirements.txt previously.
   if [ -f "requirements.txt" ]; then
      # see https://medium.com/@boscacci/why-and-how-to-make-a-requirements-txt-f329c685181e
      pip3 install -r requirements.txt
   else
      h2 "No requirements.txt, so use pip to install for imports ..."

      if [ "${RUN_ANACONDA}" = true ]; then  # -A

         if [ "${PACKAGE_MANAGER}" == "brew" ]; then # -U
            if ! command -v anaconda ; then
               h2 "brew cask install anaconda ..."
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
         #note "$( conda info )"  # VERBOSE
         #note "$( conda list anaconda$ )"
         #note "$( anaconda version )"  

         export PREFIX="/usr/local/anaconda3"
         export   PATH="/usr/local/anaconda3/bin:$PATH"

         # conda create -n PDSH python=3.7 --file requirements.txt
         # conda create -n tf tensorflow
      fi  # RUN_ANACONDA

   fi  # requirements.txt 

fi # if [ "${RUN_VIRTUALENV}" = true ]; then 


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

      note "Installing tensorflow ..."
      pip3 install tensorflow   # includes https://pypi.org/project/tensorboard/
     
      # Included in conda/anaconda:
      # pip3 install jupyterlab 
      # pip3 install matplotlib

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

   if [ ! -d "logs/func/" ]; then 
      note "/logs folder not found, so tensorboard cannot start ..."
   else
      # First, kill previous one (if it's there): https://stackoverflow.com/questions/3510673/find-and-kill-a-process-in-one-line-using-bash-and-regex
      ps_kill 'tensorboard'  # bash function defined in this file.

      note "Starting tensorboard --logdir . in background ..."
      tensorboard --logdir .  &   # See https://www.tensorflow.org/tensorboard/get_started
      # TensorBoard 2.1.1 at http://localhost:6006/ (Press CTRL+C to quit)
   fi

   h2 "Starting Jupyter with Notebook $MY_FOLDER/$MY_FILE ..."
   jupyter notebook --port 8888 "${MY_FOLDER}/${MY_FILE}" 
      # & for background run
         # jupyter: open http://localhost:8888/tree
      # The Jupyter Notebook is running at:
      # http://localhost:8888/?token=7df8adf321965117234f22973419bb92ecab4e788537b90f

   if [ "$KILL_PROCESSES" = true ]; then  # -K
      ps_kill 'tensorboard'   # bash function defined in this file.
   fi

   exit

fi  # if [ "${RUN_TENSORFLOW}" = true ];


if [ "${NODE_INSTALL}" = true ]; then  # -n

      h2 "Execute deactivate if the function exists (i.e. has been created by sourcing activate):"
      # per https://stackoverflow.com/a/57342256
      declare -Ff deactivate && deactivate

#[I 16:03:18.236 NotebookApp] Starting buffering for db5328e3-...
#[I 16:03:19.266 NotebookApp] Restoring connection for db5328e3-aa66-4bc9-94a1-3cf27e330912:84adb360adce4699bccffc00c7671793


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

fi  # if [ "${DOWNLOAD_INSTALL}" = true ]; then  # -D


if [ "${BUILD_DOCKER_IMAGE}" = true ]; then   # -b

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

   h2 "Remove dangling docker images ..."
   docker rmi -f "$( docker images -qf dangling=true )"
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


if [ "$RUN_OPEN_BROWSER" = true ]; then  # -w
   if [ "$OS_TYPE" == "macOS" ]; then  # it's on a Mac:
      sleep 3
      open http://localhost:8000/
   fi
fi
      curl -s -I -X POST http://localhost:8000/ 
      curl -s       POST http://localhost:8000/ | head -n 10  # first 10 lines

fi  # if [ "${BUILD_DOCKER_IMAGE}" = true 


# if [ "${RUN_TESTS}" = true 

   # TODO: Run tests

# fi  # if [ "${RUN_TESTS}" = true 



if [ "$RUN_DELETE_AFTER" = true ]; then  # -D
      # https://www.thegeekdiary.com/how-to-list-start-stop-delete-docker-containers/
   h2 "Deleting docker-compose active containers ..."
   CONTAINERS_RUNNING="$( docker ps -a -q )"
   note "Active containers: $CONTAINERS_RUNNING"

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

if [ "$REMOVE_GITHUB_AFTER" = true ]; then  # -C
   h2 "Delete cloned GitHub at end"
   Delete_GitHub_clone    # defined above in this file.
fi


if [ "$KILL_PROCESSES" = true ]; then  # -K
   h2 "Kill processes"
   if [ "${NODE_INSTALL}" = true ]; then  # -n
      if [ -n "${MONGO_PSID}" ]; then  # not found
         Kill_process "${MONGO_PSID}"  # invoking function above.
      fi
   fi 
fi

# EOF
