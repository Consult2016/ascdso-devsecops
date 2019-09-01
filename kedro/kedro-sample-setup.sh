#!/bin/sh 
   #sh for POSIX-compliant Bourne shell that runs cross-PACKAGE_INSTALLER

# kedro-sample-setup.sh in https://github.com/wilsonmar/DevSecOps/kedro
# This script installs what kedro needs to install,
# then clones the sample project, and runs it, all in one script,
# as described in https://wilsonmar.github.io/kedro
# But this script adds automated checks not covered in manual commands described in the tutorial.

# USAGE: This script is run by this command on MacOS/Linux Terminal:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/kedro/kedro-sample-setup.sh)"

# Coding of shell/bash scripts is described at https://wilsonmar.github.io/bash-coding
   # At this point, this script has only been written/tested on MacOS.
   # This script is idempotent because it makes a work folder and deletes it on reruns.
   # The work folder path is set in a variable so you can change it for yourself.
   # Feature flags enable deletion of 

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# CURRENT STATUS: under construction. 

### 1. Collect parameters controlling the run:

INSTALL_UTILITIES="reinstall"  # no or reinstall (yes)
INSTALL_USING_BREW="no"  # no or yes

BASHFILE="$HOME/.bash_profile"  # on Macs (alt .bashrc)
WORK_FOLDER="projects"  # as in ~/projects
WORK_REPO="kedro-sample-setup"  # by default the same name as the script file.

GITHUB_ACCOUNT="quantumblacklabs"
GITHUB_REPO="kedro"
CONDA_ENV="Kedro1"
BINARY_STORE_PATH="/usr/local/bin"

SCRIPT_PATH="src"
#SCRIPT_PATH="./kedro/fiori/example.ts"

REMOVE_AT_END="no"  # yes or no (during debugging)
# TODO: Add invocation parameter override handling


### 2. Context: Starting time stamp, OS versions, command attributes:
clear  # screen and history?

THISPGM="$0"
TIME_START="$(date -u +%s)"
# "RANDOM" only works on Bash, so for sh & Dash:
   # Use rand() and awk in POSIX, from https://mywiki.wooledge.org/Bashism:
   # For Git on Windows, see http://www.rolandfg.net/2014/05/04/intellij-idea-and-git-on-windows/
RANDOM_TIME=$(awk 'BEGIN{srand(); printf "%d\n",(rand()*999)}')  # where 999 is the maximum
LOG_DATETIME=$( date "+%Y-%m-%dT%H:%M:%S%z-$RANDOM_TIME" )
printf ">>> %s started %s \n" "$THISPGM" "$LOG_DATETIME"
#SSH_USER="$USER@$( uname -n )"  # computer node name.
# LOGFILE="$HOME/$THISPGM.$LOG_DATETIME.log"  # On MacOS: ~/Library/Logs

FREE_DISKBLOCKS_START="$(df | awk '{print $4}' | cut -d' ' -f 6)"
#TO_PRINT="$THISPGM on machine $USER starting with logging to file:"
#printf "$TO_PRINT" >$LOGFILE  # single > for new file
#printf "$TO_PRINT \n"  # to screen
printf ">>> INSTALL_UTILITIES=\"%s\" (no or yes or reinstall)\n" "$INSTALL_UTILITIES"


### OS detection to PACKAGE_INSTALLER variable:
PACKAGE_INSTALLER='unknown'  # initial value.
unamestr=$( uname )  # get from os.
if [ "$unamestr" = 'Darwin' ]; then
   PACKAGE_INSTALLER='brew'
elif [ "$unamestr" = 'Linux' ]; then
   PACKAGE_INSTALLER='linux'  
   # Based on https://askubuntu.com/questions/459402/how-to-know-if-the-running-PACKAGE_INSTALLER-is-ubuntu-or-centos-with-help-of-a-bash-scri
   if   [ -f /etc/redhat-release ]; then  # centos, Amazon Linux
       PACKAGE_INSTALLER="yum"      # use yum update
   elif [ -f /etc/lsb-release ]; then  # ubuntu 
       PACKAGE_INSTALLER="apt-get"  # use apt-get update
   fi
elif [ "$unamestr" = 'FreeBSD' ]; then
    PACKAGE_INSTALLER='pkg'  # https://www.freebsd.org/cgi/man.cgi?query=pkg-install
elif [ "$unamestr" = 'Windows' ]; then
    PACKAGE_INSTALLER='choco'
fi
if [ $PACKAGE_INSTALLER != 'brew' ]; then
   printf ">>> This script is not designed for %s  = %s.\n" "$unamestr" "$PACKAGE_INSTALLER"
   exit
else
   printf ">>> PACKAGE_INSTALLER = \"%s\" \n"  "$PACKAGE_INSTALLER"
   # uname -a  # operating sytem
fi


### 3. Shell utility functions:

# TODO: Set TRAP.
cleanup() {
    err=$?
    printf "\n>>> At cleanup() LOGFILE=%s" "$LOGFILE"

    FREE_DISKBLOCKS_END=$( df | awk '{print $4}' | cut -d' ' -f 6 ) 
#   DIFF=$(((FREE_DISKBLOCKS_START-FREE_DISKBLOCKS_END)/2048))
#   echo "$DIFF MB of disk space consumed during this script run." >>$LOGFILE
      # 380691344 / 182G = 2091710.681318681318681 blocks per GB
      # 182*1024=186368 MB
      # 380691344 / 186368 G = 2042 blocks per MB

   TIME_END=$( date -u +%s );
   DIFF=$(( TIME_END - TIME_START ))
   MSG="End of script $THISPGM after $(( DIFF/60 ))m $(( DIFF%60 ))s seconds elapsed."
   printf ">>> %s" "$MSG"
   echo -e "\n$MSG" >>$LOGFILE

   open -e $LOGFILE  # open for edit/view using default editor (TextEdit)

   #say "script ended."  # through speaker on Mac.
   trap '' EXIT INT TERM
   exit $err 
}

# Define script utility functions:
command_exists() {  # in /usr/local/bin/... if installed by brew
  command -v "$@" > /dev/null 2>&1
}


### 4. Delete local repository if it's there (for idempotency):

cd "$HOME" || exit
   if [ ! -d "$WORK_FOLDER" ]; then # NOT found:
      printf "\n>>> Creating folder path %s to hold folder created/deleted by this script... " "$HOME/$WORK_FOLDER"
       mkdir "$WORK_FOLDER"
   fi
          cd "$WORK_FOLDER" || exit

   if [   -d "$WORK_REPO" ]; then # found:
      printf "\n>>> Removing ~/%s (from previous run)...\n" "$WORK_FOLDER/$WORK_REPO"
      rm -rf "$WORK_REPO"
   fi
   if [  -d "$WORK_REPO" ]; then # NOT found:
      printf "\n>>> Folder ~/%s delete by script logic failed.\n" "$WORK_FOLDER/$WORK_REPO"
      exit
   else
      printf ">>> Creating folder ~/%s ...\n" "$WORK_FOLDER/$WORK_REPO"
      mkdir "$WORK_REPO"
   fi
         cd "$WORK_REPO" || exit

   printf "PWD=%s \n" "$PWD"
   # ls -al


### 5. Pre-requisites installation utilities:

if ! command_exists python3 ; then  # not exist:
   if [ "$INSTALL_UTILITIES" = "no" ]; then
      printf "\n>>> python v3 not installed but INSTALL_UTILITIES=\"no\". Exiting...\n"
      exit
   fi
fi
   PYTHON_VERSION_INSTALLED="$( python3 --version )"
   printf "\n>>> Python version installed ==> %s \n" "$PYTHON_VERSION_INSTALLED"


if [ "$PACKAGE_INSTALLER" = "brew" ]; then

   if ! command_exists brew ; then  # so brew can be used to install other utilities:
      printf "\n>>> Installing homebrew using Ruby...\n"
      ruby -e "$( curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install) "
      brew tap caskroom/cask  # for brew cask commands to install GUI packages.
   fi

   if ! command_exists tree ; then
      printf "\n>>> Installing tree (folder display utility) using Homebrew...\n"
      brew install tree
   fi

   if ! command_exists jq ; then
      printf "\n>>> Installing jq (JSON parser utility) using Homebrew...\n"
      brew install jq
   fi

   if ! command_exists conda ; then  # not exist:
      if [ "$INSTALL_UTILITIES" = "no" ]; then
         printf "\n>>> Conda not installed but INSTALL_UTILITIES=\"no\". Exiting...\n"
         exit
      else
         brew cask install anaconda
         # if successful:
         # Initialize Conda to the Linux shell being used:
         conda init bash

         CONDA_PATH="/usr/local/anaconda3/bin"
         if grep -q "$CONDA_PATH" "$BASHFILE" ; then
            printf "\n>>> export $CONDA_PATH already in $BASHFILE \n"
         else
            printf "\n>>> Adding export $CONDA_PATH in $BASHFILE \n"
            # GOHOME="$HOME/golang1"  # where you store custom go source code
            # export GOHOME="$HOME/gits/wilsonmar/golang-samples"
         fi
      fi
   fi
   printf "\n>>> Conda version installed ==> %s \n" "$( conda --version)"

fi  # brew

get_latest_release() {
  # Based on https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}
   # Usage: $ get_latest_release "creationix/nvm"
   # Example Response: v0.31.4


exit


### 6. install Kedro cli

# Based on https://github.com/quantumblacklabs/kedro
install_kedro_cli(){
    # TODO: Identify latest version of Kedro available in 
    # https://github.com/quantumblacklabs/kedro/releases
   KEDRO_VERSION="0.15.0"

      printf "\n>>> Obtaining kedro-cli ...\n" 
      if [ "$PACKAGE_INSTALLER" = "brew" ]; then 
         # NOTE: Here "pip3" is used instead of "pip" as shown in Kendro's documentation.
         pip3 install kedro==$KEDRO_VERSION
      else  # "linux"
         printf "\n>>> At this point, this script has only been written/tested on MacOS.\n" 
      fi
}
if ! command_exists kedro ; then  # not exist:
   if [ "$INSTALL_UTILITIES" = "no" ]; then
      printf "\n>>> kedro-cli not installed but INSTALL_UTILITIES=\"no\". Exiting...\n"
      exit
   fi
      if [ "$PACKAGE_INSTALLER" = "brew" ]; then
         if [ "$INSTALL_USING_BREW" = "yes" ]; then
            printf "\n>>> Brew install kedro-io/taps/kedro ...\n"
            brew install kedro-io/taps/kedro
                #   ==> Downloading https://registry.npmjs.org/@kedro/kedro-cli/-/kedro-cli-1.0.
                # 
         else
            install_kedro_cli
         fi 
      else  # linux
         printf "\n>>> Installing kedro-cli ...\n"
         install_kedro_cli
      fi
else
   if [ "$INSTALL_UTILITIES" = "reinstall" ]; then
      printf "\n>>> Reinstalling kedro-cli ...\n"
      if [ "$PACKAGE_INSTALLER" = "brew" ]; then
         if [ "$INSTALL_USING_BREW" = "yes" ]; then
            brew upgrade kedro
               # Error: kedro-cli 1.14.1 already installed
         else
            install_kedro_cli
         fi 
      else  # linux
         install_kedro_cli
      fi
   else
      printf ">>> Using existing version \n" 
   fi
fi
printf "\n>>> Kedro-cli %s ...\n" "$( kedro --version "v" )"
# kedro -h


### 7. Clone script from GitHub

# Because its parent folder is deleted before/after use:

KEDRO_LATEST_RELEASE=$( get_latest_release "$GITHUB_ACCOUNT/$GITHUB_REPO" )
   # curl --silent "https://api.github.com/repos/$1/releases/latest" | jq -r .tag_name
printf "\n>>> Latest release in GitHub %s ...\n" "$GITHUB_ACCOUNT/$GITHUB_REPO"

exit

         if [ ! -d "$GITHUB_ACCOUNT/$GITHUB_REPO" ]; then  # folder not there
            fancy_echo "Creating folder $GITHUB_ACCOUNT/$GITHUB_REPO ..."
            # option: populate by git clone https://github.com/wilsonmar/golang-samples"
            git clone https://github.com/$GITHUB_ACCOUNT/$GITHUB_REPO  --depth=1 
               # --depth=1 used to reduce disk space and download time if only latest master is used.
               # RESPONSE: Receiving objects: 100% (1075/1075), 2.17 MiB | 1.43 MiB/s, done.
            cd $GITHUB_REPO
         fi

SCRIPT_PATH="04-Challenging_DOM.ts"
#SCRIPT_PATH="./kedro/fiori/example.ts"


### 8. Run the script

if [ REMOVE_AT_END = "no" ]; then 
   printf "\n>>> npx running script %s \n" "$SCRIPT_PATH"
   npx @kedro/kedro-cli run "$SCRIPT_PATH" --no-headless
else
   printf "\n>>> kedro running script %s \n" "$SCRIPT_PATH"
   kedro run "$SCRIPT_PATH" --no-headless
fi

### 9. Clean up

if [ "$REMOVE_AT_END" = "yes" ]; then
   printf "\n>>> Removing WORK_REPO=%s in %s \n" "$WORK_REPO" "$PWD"
   rm -rf "$WORK_REPO"
fi

# per https://kubedex.com/troubleshooting-aws-iam-authenticator/
# For an automated installation the process involves pre-generating some config and certs, updating a line in the API Server manifest and installing a daemonset.

