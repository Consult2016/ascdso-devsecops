#!/bin/sh 
   #for POSIX-compliant Bourne shell that runs cross-platform

# azure-locust-perftest.sh in https://github.com/wilsonmar/DevSecOps/azure
#
# This script installs utilities for using azure shell scripts run in the AWS cloud.
# as described in https://microsoft.github.io/PartsUnlimitedMRP/pandp/200.1x-PandP-LocustTest.html
# referenced from https://wilsonmar.github.io/azure-devops
# 
# This script adds automated checks not covered in manual commands, which assumes you know how to debug.
# This script is idempotent because it makes a work folder and deletes it on reruns.
#
# USAGE: This script is run by this command on MacOS/Linux Terminal or within Git Bash on Windows:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/Azure/azure-locust-perftest/azure-locust-perftest.sh)"
#
# Coding techniques in this shell/bash script is described at https://wilsonmar.github.io/bash-coding
#
# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# CURRENT STATUS: under construction. just copied from another to adapt.

### 1. Collect parameters controlling the run:

INSTALL_UTILITIES="reininstall"  # no or reinstall (=yes)
INSTALL_USING_BREW="no"  # no or yes
WORK_FOLDER="projects"  # as specified in course materials.
WORK_REPO="azure-locust-perftest"  # same as script name
BINARY_STORE_PATH="/usr/local/bin"
VENV_PATH="venv"
SCRIPT_PATH="04-Challenging_DOM.ts"
#SCRIPT_PATH="./element/fiori/example.ts"

REMOVE_AT_END="no"  # yes or no during debugging.

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
   printf ">>> Platform = %s \n"  "$PLATFORM"
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
      printf "\n>>> Removing ~/%s from previous run ...\n" "$WORK_FOLDER/$WORK_REPO"
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

### 6.1 install azure_cli

install_azure_cli(){
   exit
   # Based on https://element.azure.io/docs/1.0/install
      printf "\n>>> Obtaining azure-cli ...\n" 
      if [ "$PLATFORM" = "macos" ]; then  # uname -a = darwin:
         npm install -g @azure/azure-cli
      else  # "linux"
         yarn global upgrade @azure/azure-cli@beta
      fi
         printf ">>> Downloading md5 (publisher's hash) ...\n"
         if [ "$PLATFORM" = "macos" ]; then  # darwin
            curl -s https://azure-cli.s3.amazonaws.com/azure-cli-darwin-amd64-latest.md5 
            md5 -q /usr/local/bin/azure-cli
         else  # linux:
            echo "$(curl -s https://azure-cli.s3.amazonaws.com/azure-cli-linux-amd64-latest.md5) /usr/local/bin/azure-cli" | md5sum -c -
         fi

         # Comparison of hash cut out.

}
if ! command_exists az ; then  # not exist:
   if [ "$INSTALL_UTILITIES" = "no" ]; then
      printf "\n>>> azure-cli not installed but INSTALL_UTILITIES=\"no\". Exiting...\n"
      exit
   fi
      if [ "$PLATFORM" = "macos" ]; then
            printf "\n>>> Brew install azure-cli on macOS ...\n"
            brew install azure-cli
      else  # linux
         printf "\n>>> Installing azure-cli ...\n"
         install_azure_cli
      fi
else
   if [ "$INSTALL_UTILITIES" = "reinstall" ]; then
      printf "\n>>> Reinstalling azure-cli ...\n"
      if [ "$PLATFORM" = "macos" ]; then
            brew upgrade azure-cli
               # Error: azure-cli 1.14.1 already installed
      else  # linux
         install_azure_cli
      fi
   else
      printf ">>> Using existing version:\n" 
   fi
fi
printf ">>> %s\n" "$( az --version | grep azure-cli )" # 2.0.68
# az --help

### 6.2 install Python (and pip)

### 6.3 install Flask

if ! command_exists flask ; then  # not exist:
   if [ "$INSTALL_UTILITIES" = "no" ]; then
      printf "\n>>> flask not installed but INSTALL_UTILITIES=\"no\". Exiting...\n"
      exit
   fi
      if [ "$PLATFORM" = "macos" ]; then
            printf "\n>>> pip install flask on macOS ...\n"
            pip install flask
      #else  # linux
      #   printf "\n>>> Installing flask on ...\n"
         # install_flask
      fi
else
      printf ">>> Using existing version:\n" 
fi
printf ">>> %s\n" "$( flask --version | grep Flask )" 
   # Flask 0.12.2
   # Python 2.7.10 (default, Feb 22 2019, 21:17:52)
   # [GCC 4.2.1 Compatible Apple LLVM 10.0.1 (clang-1001.0.37.14)]

### 6.4 install tree

if ! command_exists tree ; then  # not exist:
   if [ "$INSTALL_UTILITIES" = "no" ]; then
      printf "\n>>> tree not installed but INSTALL_UTILITIES=\"no\". Exiting...\n"
      exit
   fi
      if [ "$PLATFORM" = "macos" ]; then
            printf "\n>>> pip install tree on macOS ...\n"
            pip install tree
      else  # linux
         printf "\n>>> Installing tree on ...\n"
         # install_tree
      fi
else
      printf ">>> Using existing version:\n" 
fi
printf ">>> %s\n" "$( tree --version )" 
   # tree v1.8.0 (c) 1996 - 2018 by Steve Baker, Thomas Moore, Francesc Rocher, Florian Sesser, Kyosuke Tokoro


### 6.5 install locustio

# brew link --overwrite python  # doesn't work.
brew unlink python && brew link python
   # Unlinking /usr/local/Cellar/python/3.7.4... 24 symlinks removed
   # Linking /usr/local/Cellar/python/3.7.4... 24 symlinks created
python --version

if ! command_exists locust ; then  # not exist:
   if [ "$INSTALL_UTILITIES" = "no" ]; then
      printf "\n>>> locustio not installed but INSTALL_UTILITIES=\"no\". Exiting...\n"
      exit
   fi
      if [ "$PLATFORM" = "macos" ]; then
            printf "\n>>> pip install locustio on macOS ...\n"
            pip install locustio
            # https://docs.locust.io/en/stable/
      else  # linux
         printf "\n>>> Installing locustio on ...\n"
         # install_locustio
      fi
else
      printf ">>> Using existing version:\n" 
fi
printf ">>> %s\n" "$( locust --version )" 
   # 


### 7. Clone script 

# Because its parent folder is deleted before/after use:
   printf "PWD=%s" "$PWD"

   printf "\n>>> wget Python.gitignore ...\n"
wget -O .gitignore "https://github.com/github/gitignore/blob/master/Python.gitignore" 2> templog

   printf "\n>>> Construct app/app.py ...\n"
touch __init__.py

mkdir app && cd app
touch __init__.py
# wget
curl -o app.py "https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/Azure/azure-locust-perftest/app.py"
curl -o locustio.py "https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/Azure/azure-locust-perftest/locustio.py"

tree

exit
##### here is where I stopped.


### 8. Start app server under test

   printf "\n>>> Run python app/app.py &  # in background ...\n"
python app/app.py  &
   # * Running on http://127.0.0.1:5000/ (Press CTRL+C to quit)
   # * Restarting with stat
   # * Debugger is active!
   # * Debugger PIN: 450-716-582

   printf "\n>>> Verify curl for json response ...\n"
curl -X GET http://127.0.0.1:5000/tests
   # "description": "testing individual units of source code", 
   # "name": "unit testing"

### 9. Start our Flask API using 

   python app/app.py 
   
   # Start Locust: 
   
   locust --host=http://localhost:5000.


exit



### 8. Create Python virtual environment for our Flask application

if ! command_exists python3 ; then  # not exist:
      printf "\n>>> python3 not installed but INSTALL_UTILITIES=\"no\". Exiting...\n"
      exit
else
   printf "\n>>> python3 -m venv %s \n" "$VENV_PATH"
   python3 -m venv "$VENV_PATH"
   ls "$VENV_PATH"
fi


exit

git clone https://github.com/daeep/azure_Element && cd azure_Element

SCRIPT_PATH="04-Challenging_DOM.ts"
#SCRIPT_PATH="./element/fiori/example.ts"


### 8. Run the script

if [ REMOVE_AT_END = "no" ]; then 
   printf "\n>>> npx running script %s \n" "$SCRIPT_PATH"
   npx @azure/azure-cli run "$SCRIPT_PATH" --no-headless
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

