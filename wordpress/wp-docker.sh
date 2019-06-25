#!/bin/sh 
#for POSIX-compliant Bourne shell that runs cross-platform

# wp-docker.sh in https://github.com/wilsonmar/DevSecOps/wordpress
# This shell script installs a WordPress instance (with a MySQL database) within Docker.
# Content here is based mostly on David Clinton's (https://hackernoon.com/@dbclin) 
# course released 10 May 2016 on Pluralsight at:
# https://app.pluralsight.com/library/courses/using-docker-aws/table-of-contents
# with code adapted from https://bootstrap-it.com/docker4aws/

# This script is run by this command on MacOS/Linux Terminal:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/wordpress/wp-docker.sh)"

# Coding of shell/bash scripts is described at https://wilsonmar.github.io/bash-coding

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# CURRENT STATUS: under construction, with TODO items.

### 1. Run Parameters controlling this run:

INSTALL_UTILITIES="reinstall"  # no or yes or reinstall
WORK_FOLDER="projects"  # within user's $HOME folder as specified in course materials.
WORK_REPO="wordpress"
# BINARY_STORE_PATH="/usr/local/bin"
      # CAUTION: Identify your cluster's Kubernetes version from Amazon S3 so you can 
      # get the corresponding version of kubectl from:
      # https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
#      K8S_VERSION="1.13.7/2019-06-11"
                 # 1.12.9/2019-06-21
                 # 1.11.10/2019-06-21
                 # 1.10.13/2019-06-21
REMOVE_AT_END="no"  # "yes" or "no"


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

   if [  -d "$WORK_REPO" ]; then # found:
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

   printf "\n>>> Downloading wp-docker.sh from GitHub .../n"
   curl -o wp-docker.sh        "https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/wordpress/wp-docker.sh"
   
   # After using http://www.yamllint.com/ to lint each yml file:
   printf "\n>>> Downloading wordpress-stack.yml from GitHub .../n"
   curl -o wordpress-stack.yml "https://github.com/wilsonmar/DevSecOps/blob/master/wordpress/wordpress-stack.yml"
   
   printf "\n>>> Downloading docker-compose.yml from GitHub (see course Discussions).../n"
   curl -o docker-compose.yml "https://github.com/wilsonmar/DevSecOps/blob/master/wordpress/docker-compose.yml"
   
   printf "PWD=%s" "$PWD"
   ls -al

### 4. Pre-requisites utilities installation

   if ! command_exists git ; then
      if [ "$PLATFORM" == "macos" ]; then  # uname = "Darwin":
         brew install git
      else  # Based on https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
         if [ -f /etc/redhat-release ]; then
            PLATFORM="yum"      # yum update
         elif [ -f /etc/lsb-release ]; then
            PLATFORM="apt-get"  # apt-get update
         fi
      fi
   fi

# Per 3:46 into https://app.pluralsight.com/player?course=using-docker-aws&author=david-clinton&name=440cc04e-14c6-45e5-ba8d-2df97c1b1358&clip=1&mode=live

   if ! command_exists awscli ; then
      # See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html
      if [ "$PLATFORM" == "macos" ]; then  # uname = "Darwin":
         brew install awscli
      else  # Based on https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
         if [ -f /etc/redhat-release ]; then
            PLATFORM="yum"      # yum update
         elif [ -f /etc/lsb-release ]; then
            PLATFORM="apt-get"  # apt-get update
         fi
      fi
   fi

### 6. 

STACK_YML="wordpress-stack.yml"
STACK_NAME="mywordpress"

printf "\n>>> Remove manager from prior run: docker swarm leave --force ...\n"
   docker swarm leave --force
      #RESPONSE: Node left the swarm.

# Per 3:39 into https://app.pluralsight.com/player?course=using-docker-aws&author=david-clinton&name=440cc04e-14c6-45e5-ba8d-2df97c1b1358&clip=1&mode=live
printf "\n>>> docker swarm init ...\n"
   docker swarm init
      # Swarm initialized: current node (x3t9fal0if4a84mn7o5y1o6mf) is now a manager.
      # To add a worker to this swarm, run the following command:
      # docker swarm join --token SWMTKN-1-0l1x7cjd605n2m1uo3w2il86kngdb2q0otzzhf2du2idshr0xw-0otui67aoq7r7tf7h3meqk6g1 192.168.65.3:2377
      # To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

printf "\n>>> docker stack deploy -c wordpress-stack.yml %s ...\n" "$STACK_NAME"
   docker stack deploy -c "$STACK_YML"  "$STACK_NAME"
   # shellcheck disable=SC2181
   if [ $? -ne 0 ]; then
      printf "\n>>> RETURN=%s (1 = bad/STOP, 0 = good)\n" "$?"
   fi

# The EC2 Launch type requires a docker-compose.yml file.   
printf "\n>>> Loop so the services can take up to 5 minutes to get ready...\n"
   # loop
printf ">>> docker stack services %s ..." "$STACK_NAME"
   docker stack services "$STACK_NAME"
   # Nothing found in stack: mywordpress
   #or EXPECTED RESPONSE:
   # ID                  NAME                    MODE                REPLICAS            IMAGE               PORTS
   # hqecugqy68we        mywordpress_db          replicated          1/1                 mysql:latest
   # ytlni7w589pf        mywordpress_wordpress   replicated          1/1                 wordpress:latest    *:80->80/tcp
   # shellcheck disable=SC2181
   if [ $? -ne 0 ]; then
      printf "\n>>> RETURN=%s (1 = bad/STOP, 0 = good)\n" "$?"
   fi

#yaml: line 607: mapping values are not allowed in this context

printf "\n>>> Get IP address ...\n"  # Instead of "ip a" shown in video:
      # 	inet 192.168.0.195/24 brd 192.168.0.255 en0
   WORK_IP=$( ifconfig en0 | grep inet | grep -v inet6 | awk '{print $2}' )
   #TODO: WORK_PORT is extracted from specification in yml file.
printf ">>> Verify http://%s using curl of first 4 HTML lines ...\n" "$WORK_IP"
   # Verify HTML returned (using HTTP because no SSL used during testing):
   curl -s "http://$WORK_IP:80" | tail -4


### 9. 

if [ "$REMOVE_AT_END" = "yes" ]; then
   printf "\n>>> Removing WORK_REPO=%s in %s \n" "$WORK_REPO" "$PWD"
   rm -rf "$WORK_REPO"
fi

