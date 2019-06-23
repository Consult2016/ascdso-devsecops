#!/bin/sh #for POSIX-compliant Bourne shell that runs cross-platform

# eks-setup.sh in https://github.com/wilsonmar/DevSecOps/docker-production-aws
# as described in https://wilsonmar.github.io/docker-production-aws.

# This script installs utilities for using Kubernetes within AWS.
# Content is based partly on David Clinton's course released 10 May 2016 on Pluralsight at:
# https://app.pluralsight.com/library/courses/using-docker-aws/table-of-contents
# But here rather than installing to ~/bin, I install to /usr/local/bin.

# This script is run by this command on MacOS/Linux Terminal:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/docker-production-aws/eks-setup.sh)"

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# CURRENT STATUS: under construction, with TODO items.

### 1. Run Parameters controlling this run:

INSTALL_UTILITIES="reinstall"  # no or yes or reinstall
WORK_FOLDER="docker-production-aws"  # as specified in course materials.
WORK_REPO="eks-setup"
BINARY_STORE_PATH="/usr/local/bin"
# TODO: Add operating system detection:
OS="mac"  # "mac" or "linux"
      # CAUTION: Identify your cluster's Kubernetes version from Amazon S3 so you can 
      # get the corresponding version of kubectl from:
      # https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
      K8S_VERSION="1.13.7/2019-06-11"
                 # 1.12.9/2019-06-21
                 # 1.11.10/2019-06-21
                 # 1.10.13/2019-06-21
REMOVE_AT_END="no"  # or no

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
echo ">>> INSTALL_UTILITIES=\"$INSTALL_UTILITIES\" (no or yes or reinstall)"

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


### 4. Delete local repository if it's there (for idempotency):

cd "$HOME"
   echo "\n>>> Creating folder $HOME/projects if it's not there:"
   if [ ! -d "projects" ]; then # NOT found:
      mkdir projects
   fi
         cd projects

   if [ ! -d "$WORK_FOLDER" ]; then # NOT found:
      echo "\n>>> Creating folders $HOME/project/$WORK_FOLDER if it's not there:"
      mkdir "$WORK_FOLDER"
   fi
          cd "$WORK_FOLDER"

   if [  -d "$WORK_REPO" ]; then # found:
      echo "\n>>> Removing ~/projects/$WORK_FOLDER/$WORK_REPO from previous run:"
      rm -rf "$WORK_REPO"
   fi
   if [ ! -d "$WORK_REPO" ]; then # NOT found:
      mkdir "$WORK_REPO"
   fi
          cd "$WORK_REPO"

   if [[ "$REMOVE_AT_END" != "yes" ]]; then
      echo "\n>>> Downloading eks-setup.sh (this shell script) ..."
      curl -o eks-setup.sh "https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/docker-production-aws/eks-setup.sh"
   fi

echo "PWD=$PWD"


### 5. Pre-requisites installation

# Based on course: https://app.pluralsight.com/player?course=using-docker-aws&author=david-clinton&name=b874bb63-9ca2-4fa3-8d52-853c70953d8a&clip=1&mode=live

### 5.1 install eksctl

install_eksctl(){
   # This is the alternatative to download directly instead of brew install:
      # Based on ?:?? into https://app.pluralsight.com/player?course=using-docker-aws&author=david-clinton&name=b874bb63-9ca2-4fa3-8d52-853c70953d8a&clip=1&mode=live
      echo ">>> Obtaining eksctl for latest K8S_VERSION=$K8S_VERSION..."
      # CAUTION: Get latest version from https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html
      if [[ "$OS" == "mac" ]]; then  # uname -a = darwin:
         curl --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
      else  # "linux"
         curl --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
      fi
      if [ ! -f "/tmp/eksctl" ]; then # NOT found:
         echo ">>> eksctl file download failed. Exiting..."
         exit
      else
         echo ">>> Downloading eksctl.sha256 (publisher's hash) ..."  # 
         if [[ "$OS" == "mac" ]]; then  # darwin
            curl -o eksctl.sha256 "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/darwin/amd64/eksctl.sha256"
         else  # linux:
            curl -o eksctl.sha256 "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/linux/amd64/eksctl.sha256"         
         fi
         cat eksctl.sha256 
         echo "/n"
         # Comparison of hash cut out.

         # ls -al eksctl # 20.5M from ls -al /tmp/eksctl  # 
         echo ">>> Moving eksctl file to $BINARY_STORE_PATH. Password required here..."
         sudo mv /tmp/eksctl "$BINARY_STORE_PATH"  # so it can be called from anywhere.
         ls -al   "$BINARY_STORE_PATH/eksctl"
         chmod +x "$BINARY_STORE_PATH/eksctl"
      fi
}
if ! command_exists eksctl ; then  # not exist:
   if [[ "$INSTALL_UTILITIES" == "no" ]]; then
      echo "\n>>> eksctl not installed but INSTALL_UTILITIES=/"no/". Exiting..."
      exit
   fi
      # brew search No formula or cask found for "eksctl", so brew not used:
      #if [[ "$OS" == "mac" ]]; then
      #   echo "\n>>> Brew Installing eksctl ..."  # 
      #   brew install eksctl
      #else
         echo "\n>>> Installing eksctl ..."
         install_eksctl
      #fi
else  # new or reinstall:
   if [[ "$INSTALL_UTILITIES" == "reinstall" ]]; then
      echo "\n>>> Reinstalling eksctl ..."
      #if [[ "$" == "mac" ]]; then
      #   brew upgrade eksctl
      #else
         install_eksctl
      #fi
   else
      echo "\n>>> Using existing version:" 
   fi
fi
echo ">>> eksctl ==> $( eksctl version )"  # [ℹ]  version.Info{BuiltAt:"", GitCommit:"", GitTag:"0.1.38"}


### 5.2 install aws-iam-authenticator

install_aws_iam_authenticator(){
   # This is the alternatative to download directly instead of brew install:
      # Based on 3:22 into https://app.pluralsight.com/player?course=using-docker-aws&author=david-clinton&name=b874bb63-9ca2-4fa3-8d52-853c70953d8a&clip=1&mode=live
      echo ">>> Obtaining aws-iam-authenticator for K8S_VERSION=$K8S_VERSION..."
      # CAUTION: Get latest version from https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
      if [[ "$OS" == "mac" ]]; then  # uname -a = darwin:
         curl -o aws-iam-authenticator "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/darwin/amd64/aws-iam-authenticator"
              #% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
              #  Dload  Upload   Total   Spent    Left  Speed
              # 76 17.7M   76 13.5M    0     0   771k      0  0:00:23  0:00:17  0:00:06  748k^C
      else  # "linux"
         curl -o aws-iam-authenticator "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/linux/amd64/aws-iam-authenticator"
      fi
      if [ ! -f "aws-iam-authenticator" ]; then # NOT found:
         echo ">>> aws-iam-authenticator file download failed. Exiting..."
         exit
      else
         echo ">>> Downloading aws-iam-authenticator.sha256 (publisher's hash) ..."  # 
         if [[ "$OS" == "mac" ]]; then  # darwin
            curl -o aws-iam-authenticator.sha256 "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/darwin/amd64/aws-iam-authenticator.sha256"
         else  # linux:
            curl -o aws-iam-authenticator.sha256 "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/linux/amd64/aws-iam-authenticator.sha256"
         fi
         # ls -al aws-iam-authenticator.sha256  # 
         if [ ! -f aws-iam-authenticator.sha256 ]; then # NOT found:
            echo ">>> aws-iam-authenticator.sha256 download failed!"
            exit
         else
            PUB_SHA256_HASH=$( cat aws-iam-authenticator.sha256 | cut -d " " -f 1 )
               # SHA256_HASH=cc35059999bad461d463141132a0e81906da6c23953ccdac59629bb532c49c83 aws-iam-authenticator
               # cut to:     cc35059999bad461d463141132a0e81906da6c23953ccdac59629bb532c49c83 aws-iam-authenticator
            echo ">>> PUB_SHA256_HASH=$PUB_SHA256_HASH<"
            rm aws-iam-authenticator.sha256

            LOC_SHA256_HASH=$( sha256sum aws-iam-authenticator  | cut -d " " -f 1 )
            echo ">>> LOC_SHA256_HASH=$LOC_SHA256_HASH<"
               # cc35059999bad461d463141132a0e81906da6c23953ccdac59629bb532c49c83 aws-iam-authenticator

            if [ "$PUB_SHA256_HASH" == "$LOC_SHA256_HASH" ]; then
               echo ">>> Hashes match!"
            else
               echo ">>> ERROR: Hashes do NOT match! Exiting..."
               exit
            fi
         fi

         echo ">>> Moving kubectl file to $BINARY_STORE_PATH. Password required here..."
         sudo mv kubectl "$BINARY_STORE_PATH"  # so it can be called from anywhere.
         ls -al   "$BINARY_STORE_PATH/kubectl"
         chmod +x "$BINARY_STORE_PATH/kubectl"
         echo ">>> Moving aws-iam-authenticator file to $BINARY_STORE_PATH. Password required here..."
         sudo mv aws-iam-authenticator "$BINARY_STORE_PATH"  # so it can be called from anywhere.
         ls -al   "$BINARY_STORE_PATH/aws-iam-authenticator"
         chmod +x "$BINARY_STORE_PATH/aws-iam-authenticator"
      fi
}
if ! command_exists aws-iam-authenticator ; then  # not exist:
   if [[ "$INSTALL_UTILITIES" == "no" ]]; then
      echo "\n>>> aws-iam-authenticator not installed but INSTALL_UTILITIES=/"no/". Exiting..."
      exit
   fi
      # brew version of aws-iam-authenticator displays "unversioned", so not used:
      #if [[ "$OS" == "mac" ]]; then
      #   echo "\n>>> Brew Installing aws-iam-authenticator ..."
      #   brew install aws-iam-authenticator
      #else
         echo "\n>>> Installing aws-iam-authenticator ..."
         install_aws_iam_authenticator
            # Downloading https://homebrew.bintray.com/bottles/kubernetes-cli-1.15.0.mojave.bottle.tar.gz
            # 🍺  /usr/local/Cellar/aws-iam-authenticator/0.4.0: 5 files, 31.1MB
      #fi
else  # new or reinstall:
   if [[ "$INSTALL_UTILITIES" == "reinstall" ]]; then
      echo "\n>>> Reinstalling aws-iam-authenticator ..."
      #if [[ "$" == "mac" ]]; then
      #   brew upgrade aws-iam-authenticator
      #else
         install_aws_iam_authenticator
      #fi
   else
      echo "\n>>> Using existing version:" 
   fi
fi
echo ">>> aws-iam-authenticator ==> $( aws-iam-authenticator version )"
         # {"Version":"v0.4.0","Commit":"c141eda34ad1b6b4d71056810951801348f8c367"}


### 5.3 install kubectl

# See https://matthewpalmer.net/kubernetes-app-developer/articles/guide-install-kubernetes-mac.html


install_kubectl(){
   # Kubernetes uses the kubectl command line utility for communicating with the cluster API server. 
   # This is the alternatative to download directly instead of brew install:
      # Based on 3:22 into https://app.pluralsight.com/player?course=using-docker-aws&author=david-clinton&name=b874bb63-9ca2-4fa3-8d52-853c70953d8a&clip=1&mode=live
      echo ">>> Obtaining kubectl for K8S_VERSION=$K8S_VERSION..."
      # CAUTION: Identify your cluster's Kubernetes version from Amazon S3 so you can 
      # get the corresponding version of kubectl from:
      # https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
      K8S_VERSION="1.13.7/2019-06-11"
                 # 1.12.9/2019-06-21
                 # 1.11.10/2019-06-21
                 # 1.10.13/2019-06-21
      if [[ "$OS" == "mac" ]]; then  # uname -a = darwin:
         curl -o kubectl "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/darwin/amd64/kubectl"
      else  # "linux"
         curl -o kubectl "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/linux/amd64/kubectl"
      fi
      if [ ! -f "kubectl" ]; then # NOT found:
         echo ">>> kubectl file download failed. Exiting..."
         exit
      else
         echo ">>> Downloading kubectl.sha256 (publisher's hash) ..."  # 
         if [[ "$OS" == "mac" ]]; then  # darwin
            curl -o kubectl.sha256 "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/darwin/amd64/kubectl.sha256"
         else  # linux:
            curl -o kubectl.sha256 "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/linux/amd64/kubectl.sha256"
         fi
         # ls -al kubectl.sha256  # 
         if [ ! -f kubectl.sha256 ]; then # NOT found:
            echo ">>> kubectl.sha256 download failed!"
            exit
         else
            PUB_SHA256_HASH=$( cat kubectl.sha256 | cut -d " " -f 1 )
            echo ">>> PUB_SHA256_HASH=$PUB_SHA256_HASH<"
            rm kubectl.sha256

            LOC_SHA256_HASH=$( sha256sum kubectl  | cut -d " " -f 1 )
            echo ">>> LOC_SHA256_HASH=$LOC_SHA256_HASH<"

            if [ "$PUB_SHA256_HASH" == "$LOC_SHA256_HASH" ]; then
               echo ">>> Hashes match!"
            else
               echo ">>> ERROR: Hashes do NOT match! Exiting..."
               exit
            fi
         fi

         # ls -al kubectl # 20.5M from ls -al /tmp/kubectl  # 
         echo ">>> Moving kubectl file to $BINARY_STORE_PATH. Password required here..."
         sudo mv kubectl "$BINARY_STORE_PATH"  # so it can be called from anywhere.
         ls -al   "$BINARY_STORE_PATH/kubectl"
         chmod +x "$BINARY_STORE_PATH/kubectl"
      fi
}
if ! command_exists kubectl ; then  # not exist:
   if [[ "$INSTALL_UTILITIES" == "no" ]]; then
      echo "\n>>> kubectl not installed but INSTALL_UTILITIES=\"no\". Exiting..."
      exit
   fi
      # brew version of kubectl displays "unversioned", so not used:
      #if [[ "$OS" == "mac" ]]; then
      #   echo "\n>>> Brew Installing kubectl ..."
      #   brew install kubectl
      #else
         echo "\n>>> Installing kubectl new ..."
         install_kubectl
            # Downloading https://homebrew.bintray.com/bottles/kubernetes-cli-1.15.0.mojave.bottle.tar.gz
            # 🍺  /usr/local/Cellar/kubectl/0.4.0: 5 files, 31.1MB
      #fi
else  # new or reinstall:
   if [[ "$INSTALL_UTILITIES" == "reinstall" ]]; then
      echo "\n>>> Reinstalling kubectl ..."
      #if [[ "$" == "mac" ]]; then
      #   brew upgrade kubectl
      #else
         install_kubectl
      #fi
   else
      echo "\n>>> Using existing version:" 
   fi
fi
echo ">>> kubectl ==> $( kubectl version --short --client )"  # Client Version: v1.13.7-eks-c57ff8




# after ssh Inside a container:
# 3:30 into https://app.pluralsight.com/player?course=docker-production-using-amazon-web-services&author=justin-menga&name=docker-production-using-amazon-web-services-m6&clip=7&mode=live
# Configure host networking mode for the container by setting the --net flag to "host":
# so that Vert.x binds to eth0 network interface rather than docker0 
# docker run -it --rm --net-hotst alphine ifconfig


if [[ "$REMOVE_AT_END" == "yes" ]]; then
   echo "\n>>> Removing WORK_REPO=$WORK_REPO in $PWD"
   rm -rf "$WORK_REPO"
fi

# per https://kubedex.com/troubleshooting-aws-iam-authenticator/
# For an automated installation the process involves pre-generating some config and certs, updating a line in the API Server manifest and installing a daemonset.

