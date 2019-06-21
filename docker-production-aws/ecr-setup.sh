#!/bin/sh #for POSIX-compliant Bourne shell that runs cross-platform

# ecr-setup.sh in https://github.com/wilsonmar/DevSecOps/docker-production-aws
# as described in https://wilsonmar.github.io/docker-production-aws.

# This script builds from source the microtrader sample app used in 
# Justin Menga's course released 10 May 2016 on Pluralsight at:
# https://app.pluralsight.com/library/courses/docker-production-using-amazon-web-services/table-of-contents
# which shows how to install a "microtraders" Java app in aws using Docker, ECS, CloudFormation, etc.

# This script is run by this command on MacOS/Linux Terminal:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/docker-production-aws/docker-production-aws-setup.sh)"

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# CURRENT STATUS: under construction, with TODO items.

### 1. Run Parameters controlling this run:

INSTALL_UTILITIES="no"  # or yes
WORK_FOLDER="docker-production-aws"  # as specified in course materials.

### 2. Context: Starting time stamp, OS versions, command attributes:

clear  # screen
# For Git on Windows, see http://www.rolandfg.net/2014/05/04/intellij-idea-and-git-on-windows/
TIME_START="$(date -u +%s)"
FREE_DISKBLOCKS_START="$(df | awk '{print $4}' | cut -d' ' -f 6)"
THISPGM="$0"
# ISO-8601 plus RANDOM=$((1 + RANDOM % 1000))  # 3 digit random number.
LOG_DATETIME=$(date +%Y-%m-%dT%H:%M:%S%z)-$((1 + RANDOM % 1000))
LOGFILE="$HOME/$THISPGM.$LOG_DATETIME.log"
SSH_USER="$USER@$( uname -n )"  # computer node name.
#TO_PRINT="$THISPGM on machine $USER starting with logging to file:"
echo ">>> $LOGFILE"
#echo "$TO_PRINT" >$LOGFILE  # single > for new file
echo "$TO_PRINT"  # to screen
uname -a  # operating sytem


### 3. Shell utility functions:

cleanup() {
    err=$?
    fancy_echo "At cleanup() LOGFILE=$LOGFILE"
    #open -a "Atom" $LOGFILE
    open -e $LOGFILE  # open for edit using TextEdit
    #rm $LOGFILE
   FREE_DISKBLOCKS_END=$( df | awk '{print $4}' | cut -d' ' -f 6 ) 
#   DIFF=$(((FREE_DISKBLOCKS_START-FREE_DISKBLOCKS_END)/2048))
#   fancy_echo "$DIFF MB of disk space consumed during this script run." >>$LOGFILE
      # 380691344 / 182G = 2091710.681318681318681 blocks per GB
      # 182*1024=186368 MB
      # 380691344 / 186368 G = 2042 blocks per MB

   TIME_END=$( date -u +%s );
   DIFF=$(( TIME_END - TIME_START ))
   MSG="End of script $THISPGM after $(( DIFF/60 ))m $(( DIFF%60 ))s seconds elapsed."
   fancy_echo "$MSG"
   echo -e "\n$MSG" >>$LOGFILE

   #say "script ended."  # through speaker on Mac.

   trap '' EXIT INT TERM
   exit $err 
}

command_exists() {  # in /usr/local/bin/... if installed by brew
  command -v "$@" > /dev/null 2>&1
}


### 4. Pre-requisites installation

if [[ "$INSTALL_UTILITIES" == "yes" ]]; then

   # Install OSX

   if ! command_exists brew ; then
      fancy_echo "Installing homebrew using Ruby..."
      ruby -e "$( curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install) "
      brew tap caskroom/cask
   fi
   
   if ! command_exists packer ; then
      brew install packer
   fi
   
   if ! command_exists jq ; then
      brew install jq  # to handle JSON
   fi
   
   # https://github.com/lightbend/config
   # Typesafe configuration library for JVM languages using HOCON files https://lightbend.github.io/config/
   # for friendlier 12-factor environment variable based configuration support.

   ## Per https://github.com/wilsonmar/aws-starter
   pip install ansible awscli boto3 netaddr

fi

### 5. Delete local repository if it's there (for idempotency):

cd "$HOME"
   echo "\n>>> Creating folder $HOME/projects if it's not there:"
   if [ ! -d "projects" ]; then # NOT found:
      mkdir projects
   fi
         cd projects
   echo "PWD=$PWD"

   if [ ! -d "$WORK_FOLDER" ]; then # NOT found:
      echo "\n>>> Creating folders $HOME/project/$WORK_FOLDER if it's not there:"
      mkdir "$WORK_FOLDER"
   else
      echo "\n>>> Removing ~/projects/$WORK_FOLDER from previous run:"
      rm -rf "$WORK_FOLDER"
   fi
          cd "$WORK_FOLDER"

echo "PWD=$PWD"


### 6. Fork and Download dependencies

   WORK_REPO="packer-ecs"
   # 1:23 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m2&clip=2&mode=live
   echo "\n>>> Creating folder $HOME/project/$WORK_FOLDER/$WORK_REPO if it's not there:"
   if [  -d "$WORK_REPO" ]; then # found:
      echo "\n>>> Removing ~/projects/$WORK_FOLDER from previous run:"
      rm -rf "$WORK_FOLDER"
   fi   
   git clone "https://github.com/docker-production-aws/$WORK_REPO.git"
   cd "$WORK_REPO"
   echo "PWD=$PWD"

git checkout final  # rather than master branch.
git branch
tree  # requires brew install tree

echo "PWD=$PWD"

