#!/bin/sh #for POSIX-compliant Bourne shell that runs cross-platform

# wp-docker.sh in https://github.com/wilsonmar/DevSecOps/wordpress
# as described in https://wilsonmar.github.io/docker-production-aws.

# This shell script installs a WordPress within Docker 
# Content is based mostly on David Clinton's course released 10 May 2016 on Pluralsight at:
# https://app.pluralsight.com/library/courses/using-docker-aws/table-of-contents
# with code adapted from https://bootstrap-it.com/docker4aws/

# But here rather than installing to ~/bin, I install to /usr/local/bin.
# And version codes are more recent than the 1.12.7 in https://bootstrap-it.com/docker4aws/#install-kube
# Plus, sha256sum is used instead of openssl.

# This script is run by this command on MacOS/Linux Terminal:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/wordpress/wp-docker.sh)"

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# CURRENT STATUS: under construction, with TODO items.

### 1. Run Parameters controlling this run:

INSTALL_UTILITIES="reinstall"  # no or yes or reinstall
WORK_FOLDER="projects"  # within user's $HOME folder as specified in course materials.
WORK_REPO="wordpress"
BINARY_STORE_PATH="/usr/local/bin"
      # CAUTION: Identify your cluster's Kubernetes version from Amazon S3 so you can 
      # get the corresponding version of kubectl from:
      # https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
      K8S_VERSION="1.13.7/2019-06-11"
                 # 1.12.9/2019-06-21
                 # 1.11.10/2019-06-21
                 # 1.10.13/2019-06-21
REMOVE_AT_END="no"  # "yes" or "no"

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
echo ">>> INSTALL_UTILITIES=\"$INSTALL_UTILITIES\" (no or yes or reinstall)"

### OS detection to PLATFORM variable:
PLATFORM='unknown'
unamestr=$( uname )
if [ "$unamestr" == 'Darwin' ]; then
             PLATFORM='macos'
elif [ "$unamestr" == 'Linux' ]; then
             PLATFORM='linux'  
             # TODO: use yum or apt-get ?
elif [ "$unamestr" == 'FreeBSD' ]; then
             PLATFORM='freebsd'
elif [ "$unamestr" == 'Windows' ]; then
             PLATFORM='windows'
fi
if [ $PLATFORM != 'macos' ]; then
   echo ">>> This script is not designed for $unamestr = $PLATFORM."
   exit
else
   echo ">>> Platform = \"$PLATFORM\" "
   uname -a  # operating sytem
fi


### 3. Shell utility functions:

command_exists() {  # in /usr/local/bin/... if installed by brew
  command -v "$@" > /dev/null 2>&1
}


### 4. Delete local repository if it's there (for idempotency):

cd "$HOME"
   if [ ! -d "$WORK_FOLDER" ]; then # NOT found:
      echo "\n>>> Creating folder path $HOME/$WORK_FOLDER to hold folder created/deleted by this script... "
      mkdir "$WORK_FOLDER"
   fi
          cd "$WORK_FOLDER"

   if [  -d "$WORK_REPO" ]; then # found:
      echo "\n>>> Removing ~/$WORK_FOLDER/$WORK_REPO from previous run:"
      rm -rf "$WORK_REPO"
   fi
   if [  -d "$WORK_REPO" ]; then # NOT found:
      echo "\n>>> Folder ~/$WORK_FOLDER/$WORK_REPO delete by script logic failed."
      exit
   else
      echo "\n>>> Creating folder ~/$WORK_FOLDER/$WORK_REPO ..."
      mkdir "$WORK_REPO"
   fi
         cd "$WORK_REPO"

   echo "\n>>> Downloading wp-docker.sh from GitHub ..."
   curl -o wp-docker.sh        "https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/wordpress/wp-docker.sh"
   echo "\n>>> Downloading wordpress-stack.yml from GitHub ..."
   curl -o wordpress-stack.yml "https://github.com/wilsonmar/DevSecOps/blob/master/wordpress/wordpress-stack.yml"
   echo "\n>>> Downloading docker-compose.yml from GitHub ..."
   curl -o docker-compose.yml "https://github.com/wilsonmar/DevSecOps/blob/master/wordpress/docker-compose.yml"
   echo "PWD=$PWD"
   ls -al

### 4. Pre-requisites utilities installation

   if ! command_exists git ; then
      if [[ "$PLATFORM" == "macos" ]]; then  # uname -a = darwin:
         brew install git
      #else if [[ "$PLATFORM" == "yum" ]]; then  # uname -a = darwin:
      #   yum install git
      #else if [[ "$PLATFORM" == "apt-get" ]]; then  # uname -a = darwin:
      #   apt-get install git
      fi
   fi

### 6. 

STACK_YML="wordpress-stack.yml"
STACK_NAME="mywordpress"

echo "\n>>> Remove manager from prior run: docker swarm leave --force ..."
   docker swarm leave --force
      #RESPONSE: Node left the swarm.

echo "\n>>> docker swarm init ..."
   docker swarm init
      # Swarm initialized: current node (x3t9fal0if4a84mn7o5y1o6mf) is now a manager.
      # To add a worker to this swarm, run the following command:
      # docker swarm join --token SWMTKN-1-0l1x7cjd605n2m1uo3w2il86kngdb2q0otzzhf2du2idshr0xw-0otui67aoq7r7tf7h3meqk6g1 192.168.65.3:2377
      # To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

echo "\n>>> docker stack deploy -c wordpress-stack.yml $STACK_NAME ..."
   docker stack deploy -c "$STACK_YML"  "$STACK_NAME"
   if [ $? -ne 0 ]; then
      echo "\n>>> RETURN=$? (1 = bad/STOP, 0 = good)"
   fi

echo "\n>>> docker stack services $STACK_NAME ..."
   docker stack services "$STACK_NAME"
   # ID NAME MODE REPLICAS IMAGE PORTS
   # ID                  NAME                    MODE                REPLICAS            IMAGE               PORTS
   # hqecugqy68we        mywordpress_db          replicated          1/1                 mysql:latest
   # ytlni7w589pf        mywordpress_wordpress   replicated          1/1                 wordpress:latest    *:80->80/tcp
   if [ $? -ne 0 ]; then
      echo "\n>>> RETURN=$? (1 = bad/STOP, 0 = good)"
   fi

#yaml: line 607: mapping values are not allowed in this context

echo "\n>>> Get IP address ..."
   ip a
      # lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> mtu 16384
      # 	inet 127.0.0.1/8 lo0
      # 	inet6 ::1/128
      # 	inet6 fe80::1/64 scopeid 0x1
      # en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
      # 	ether 8c:85:90:2b:ad:e9
      # 	inet6 fe80::10e1:325e:a565:1a27/64 secured scopeid 0x8
      # 	inet 192.168.0.195/24 brd 192.168.0.255 en0
# TODO: Capture from output
echo "\n>>> Verify http://$WORK_URL (such as 192.168.0.195)  ..."
   # Verify HTML returned (using HTTP because no SSL used during testing):
   curl -s "http://$WORK_URL" | tail -4


### 9. 

if [[ "$REMOVE_AT_END" == "yes" ]]; then
   echo "\n>>> Removing WORK_REPO=$WORK_REPO in $PWD"
   rm -rf "$WORK_REPO"
fi

