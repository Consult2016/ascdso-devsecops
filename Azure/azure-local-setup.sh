#!/bin/sh 
   #for POSIX-compliant Bourne shell that runs cross-platform

# azure-local-setup.sh in https://github.com/wilsonmar/DevSecOps/azure

# This script installs utilities for using azure shell scripts run in the AWS cloud.
# as described in https://wilsonmar.github.io/azure-perftest

# This script adds automated checks not covered in manual commands, which assumes you know how to debug.
# This script is idempotent because it makes a work folder and deletes it on reruns.

# Rather than installing to ~/bin as in the video course, I install to /usr/local/bin.
# And version codes are more recent than the 1.12.7 in https://bootstrap-it.com/docker4aws/#install-kube
# Plus, sha256sum is used instead of openssl described in https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html

# USAGE: This script is run by this command on MacOS/Linux Terminal:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/azure/azure-local-setup.sh)"

# Coding of shell/bash scripts is described at https://wilsonmar.github.io/bash-coding

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# CURRENT STATUS: under construction. just copied from another to adapt.

### 1. Collect parameters controlling the run:

INSTALL_UTILITIES="reinstall"  # no or reinstall (yes)
INSTALL_USING_BREW="no"  # no or yes
WORK_FOLDER="projects"  # as specified in course materials.
WORK_REPO="azure-local-setup"
BINARY_STORE_PATH="/usr/local/bin"

SCRIPT_PATH="04-Challenging_DOM.ts"
#SCRIPT_PATH="./element/fiori/example.ts"

REMOVE_AT_END="no"  # yes or no

### 2. Context: Starting time stamp, OS versions, command attributes:

clear  # screen

### OS detection to PLATFORM variable:
PLATFORM='unknown'
unamestr=$( uname )
if [ "$unamestr" = 'Darwin' ]; then
   PLATFORM='macos'
elif [ "$unamestr" = 'Linux' ]; then
   PLATFORM='linux'  
   # Based on https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
   if   [ -f /etc/redhat-release ]; then  # centos, Amazon Linux
       PLATFORM="yum"      # use yum update
   elif [ -f /etc/lsb-release ]; then  # ubuntu 
       PLATFORM="apt-get"  # use apt-get update
   fi
elif [ "$unamestr" = 'FreeBSD' ]; then
    PLATFORM='freebsd'
elif [ "$unamestr" = 'Windows' ]; then
    PLATFORM='windows'
fi
if [ $PLATFORM != 'macos' ]; then
   printf ">>> This script is not designed for %s  = %s.\n" "$unamestr" "$PLATFORM"
   exit
else
   printf ">>> Platform = \"%s\" \n"  "$PLATFORM"
   # uname -a  # operating sytem
fi

#TIME_START="$(date -u +%s)"
#FREE_DISKBLOCKS_START="$(df | awk '{print $4}' | cut -d' ' -f 6)"
#THISPGM="$0"
# "RANDOM" only works on Bash, so for sh & Dash:
   # Use rand() and awk in POSIX, from https://mywiki.wooledge.org/Bashism:
   # For Git on Windows, see http://www.rolandfg.net/2014/05/04/intellij-idea-and-git-on-windows/
RANDOM_TIME=$(awk 'BEGIN{srand(); printf "%d\n",(rand()*999)}')  # where 999 is the maximum
LOG_DATETIME=$( date "+%Y-%m-%dT%H:%M:%S%z-$RANDOM_TIME" )
#SSH_USER="$USER@$( uname -n )"  # computer node name.
LOGFILE="$HOME/$THISPGM.$LOG_DATETIME.log"  # On MacOS: ~/Library/Logs
#TO_PRINT="$THISPGM on machine $USER starting with logging to file:"
printf ">>> LOGFILE=%s (UTC) \n" "$LOGFILE"
#printf "$TO_PRINT" >$LOGFILE  # single > for new file
#printf "$TO_PRINT \n"  # to screen

printf ">>> INSTALL_UTILITIES=\"%s\" (no or yes or reinstall)\n" "$INSTALL_UTILITIES"


### 3. Shell utility functions:

cleanup() {
    err=$?
    printf "\n>>> At cleanup() LOGFILE=%s" "$LOGFILE"
    #open -a "Atom" $LOGFILE
    open -e $LOGFILE  # open for edit using TextEdit
    #rm $LOGFILE
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

   #say "script ended."  # through speaker on Mac.

   trap '' EXIT INT TERM
   exit $err 
}

command_exists() {  # in /usr/local/bin/... if installed by brew
  command -v "$@" > /dev/null 2>&1
}


### 4. Delete local repository if it's there (for idempotency):

cd "$HOME"  || exit
   if [ ! -d "$WORK_FOLDER" ]; then # NOT found:
      printf "\n>>> Creating folder path %s to hold folder created/deleted by this script... " "$HOME/$WORK_FOLDER"
       mkdir "$WORK_FOLDER"
   fi
          cd "$WORK_FOLDER" || exit

   if [   -d "$WORK_REPO" ]; then # found:
      printf "\n>>> Removing ~/%s from previous run:\n" "$WORK_FOLDER/$WORK_REPO"
      rm -rf "$WORK_REPO"
   fi
   if [  -d "$WORK_REPO" ]; then # NOT found:
      printf "\n>>> Folder ~/%s delete by script logic failed.\n" "$WORK_FOLDER/$WORK_REPO"
      exit
   else
      printf "\n>>> Creating folder ~/%s ...\n" "$WORK_FOLDER/$WORK_REPO"
      mkdir "$WORK_REPO"
   fi
         cd "$WORK_REPO" || exit

   printf "PWD=%s" "$PWD"
   ls -al


### 5. Pre-requisites installation

if [ "$PLATFORM" = "macos" ]; then

   if ! command_exists brew ; then
      printf "\n>>> Installing homebrew using Ruby...\n"
      ruby -e "$( curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install) "
      brew tap caskroom/cask
   fi

fi

### 6. install cli

if [ REMOVE_AT_END = "no" ]; then 

install_element_cli(){
   # Based on https://element.azure.io/docs/1.0/install
      printf "\n>>> Obtaining element-cli ...\n" 
      if [ "$PLATFORM" = "macos" ]; then  # uname -a = darwin:
         npm install -g @azure/element-cli
      else  # "linux"
         yarn global upgrade @azure/element-cli@beta
      fi
         printf ">>> Downloading md5 (publisher's hash) ...\n"
         if [ "$PLATFORM" = "macos" ]; then  # darwin
            curl -s https://element-cli.s3.amazonaws.com/element-cli-darwin-amd64-latest.md5 
            md5 -q /usr/local/bin/element-cli
         else  # linux:
            echo "$(curl -s https://element-cli.s3.amazonaws.com/element-cli-linux-amd64-latest.md5) /usr/local/bin/element-cli" | md5sum -c -
         fi

         # Comparison of hash cut out.

}
if ! command_exists element-cli ; then  # not exist:
   if [ "$INSTALL_UTILITIES" = "no" ]; then
      printf "\n>>> element-cli not installed but INSTALL_UTILITIES=\"no\". Exiting...\n"
      exit
   fi
      if [ "$PLATFORM" = "macos" ]; then
         if [ "$INSTALL_USING_BREW" = "yes" ]; then
            printf "\n>>> Brew install azure/taps/element ...\n"
            brew install azure/taps/element
                #   ==> Downloading https://registry.npmjs.org/@azure/element-cli/-/element-cli-1.0.
                # 
         else
            install_element_cli
         fi 
      else  # linux
         printf "\n>>> Installing element-cli ...\n"
         install_element_cli
      fi
else
   if [ "$INSTALL_UTILITIES" = "reinstall" ]; then
      printf "\n>>> Reinstalling element-cli ...\n"
      if [ "$PLATFORM" = "macos" ]; then
         if [ "$INSTALL_USING_BREW" = "yes" ]; then
            brew upgrade azure/taps/element
               # Error: element-cli 1.14.1 already installed
         else
            install_element_cli
         fi 
      else  # linux
         install_element_cli
      fi
   else
      printf ">>> Using existing version:\n" 
   fi
fi
printf ">>> element-cli ==> %s\n" "$( element --version )" # 1.0.5
element  help

fi  # REMOVE_AT_END


### 7. Clone script from GitHub

# Because its parent folder is deleted before/after use:

git clone https://github.com/daeep/azure_Element && cd azure_Element

SCRIPT_PATH="04-Challenging_DOM.ts"
#SCRIPT_PATH="./element/fiori/example.ts"


### 8. Run the script

if [ REMOVE_AT_END = "no" ]; then 
   printf "\n>>> npx running script %s \n" "$SCRIPT_PATH"
   npx @azure/element-cli run "$SCRIPT_PATH" --no-headless
else
   printf "\n>>> element running script %s \n" "$SCRIPT_PATH"
   element run "$SCRIPT_PATH" --no-headless
fi

### 9. Clean up

if [ "$REMOVE_AT_END" = "yes" ]; then
   printf "\n>>> Removing WORK_REPO=%s in %s \n" "$WORK_REPO" "$PWD"
   rm -rf "$WORK_REPO"
fi

# per https://kubedex.com/troubleshooting-aws-iam-authenticator/
# For an automated installation the process involves pre-generating some config and certs, updating a line in the API Server manifest and installing a daemonset.

