#!/bin/sh 
   #for POSIX-compliant Bourne shell that runs cross-platform

# eks-setup.sh in https://github.com/wilsonmar/DevSecOps/docker-production-aws
# as described in https://wilsonmar.github.io/docker-production-aws.

# This script installs utilities for using Kubernetes within AWS.
# Content is based partly on David Clinton's course released 10 May 2016 on Pluralsight at:
# https://app.pluralsight.com/library/courses/using-docker-aws/table-of-contents

# This script adds automated checks not covered in manual commands, which assumes you know how to debug.
# This script is idempotent because it makes a work folder and deletes it on reruns.

# Rather than installing to ~/bin as in the video course, I install to /usr/local/bin.
# And version codes are more recent than the 1.12.7 in https://bootstrap-it.com/docker4aws/#install-kube
# Plus, sha256sum is used instead of openssl described in https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html

# This script is run by this command on MacOS/Linux Terminal:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/docker-production-aws/eks-setup.sh)"

# Coding of shell/bash scripts is described at https://wilsonmar.github.io/bash-coding

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# CURRENT STATUS: under construction. ERROR: BAD signature in ecs-cli.asc from Amazon ECS

### 1. Run Parameters controlling this run:

INSTALL_UTILITIES="reinstall"  # no or reinstall (yes)
INSTALL_USING_BREW="no"  # no or yes
WORK_FOLDER="docker-production-aws"  # as specified in course materials.
WORK_REPO="eks-setup"
BINARY_STORE_PATH="/usr/local/bin"
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

# Based on course: https://app.pluralsight.com/player?course=using-docker-aws&author=david-clinton&name=b874bb63-9ca2-4fa3-8d52-853c70953d8a&clip=1&mode=live


   if ! command_exists brew ; then
      printf "\n>>> Installing homebrew using Ruby...\n"
      ruby -e "$( curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install) "
      brew tap caskroom/cask
   fi
   
   # used in install_ecs_cli(){
   if ! command_exists gnupg ; then
      # Possible conflicting files are:
      # /usr/local/bin/gpg -> /usr/local/MacGPG2/bin/gpg2
      # /usr/local/bin/gpg-agent -> /usr/local/MacGPG2/bin/gpg-agent

      #brew install gpg2
      brew install gnupg
         # 🍺  /usr/local/Cellar/gnupg/2.2.16_1: 134 files, 11MB

      # printf '>>> export PATH="/usr/local/opt/gettext/bin:$PATH"' >> ~/.bash_profile

      # To force the link and overwrite all conflicting files:
      brew link --overwrite gnupg
         # Linking /usr/local/Cellar/gnupg/2.2.16_1... 69 symlinks created
      brew unlink gnupg && brew link gnupg
      
      # place .pem files in /usr/local/etc/openssl/certs and run
      /usr/local/opt/openssl/bin/c_rehash
         # Doing /usr/local/etc/openssl/certs
   fi


### 5.4 install ecs-cli

install_ecs_cli(){
   # Based on https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html
      printf "\n>>> Obtaining ecs-cli for latest K8S_VERSION=%s...\n" "$K8S_VERSION"
      if [ "$PLATFORM" = "macos" ]; then  # uname -a = darwin:
         curl -o /usr/local/bin/ecs-cli https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-darwin-amd64-latest
      else  # "linux"
         sudo curl -o /usr/local/bin/ecs-cli https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest
      fi

         printf ">>> Downloading md5 (publisher's hash) ...\n"
         if [ "$PLATFORM" = "macos" ]; then  # darwin
            curl -s https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-darwin-amd64-latest.md5 
            md5 -q /usr/local/bin/ecs-cli
         else  # linux:
            echo "$(curl -s https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest.md5) /usr/local/bin/ecs-cli" | md5sum -c -
         fi

         # Comparison of hash cut out.

}
if ! command_exists ecs-cli ; then  # not exist:
   if [ "$INSTALL_UTILITIES" = "no" ]; then
      printf "\n>>> ecs-cli not installed but INSTALL_UTILITIES=\"no\". Exiting...\n"
      exit
   fi
      if [ "$PLATFORM" = "macos" ]; then
         if [ "$INSTALL_USING_BREW" = "yes" ]; then
            printf "\n>>> Brew Installing ecs-cli ...\n"
            brew install amazon-ecs-cli
                #   /usr/local/Cellar/amazon-ecs-cli/1.14.1: 7 files, 44.4MB
         else
            install_ecs_cli
         fi 
      else  # linux
         printf "\n>>> Installing ecs-cli ...\n"
         install_ecs_cli
      fi
else
   if [ "$INSTALL_UTILITIES" = "reinstall" ]; then
      printf "\n>>> Reinstalling ecs-cli ...\n"
      if [ "$PLATFORM" = "macos" ]; then
         if [ "$INSTALL_USING_BREW" = "yes" ]; then
            brew upgrade amazon-ecs-cli
               # Error: amazon-ecs-cli 1.14.1 already installed
         else
            install_ecs_cli
         fi 
      else  # linux
         install_ecs_cli
      fi
   else
      printf "\n>>> Using existing version:\n" 
   fi
fi
printf ">>> ecs-cli ==> %s\n" "$( ecs-cli -v )" # ecs-cli version 1.14.1 (*UNKNOWN)

printf "\n>>> Retrieving the gpg key ...\n"
   if [ "$PLATFORM" = "macos" ]; then
      # There is a typo in Amazon's instructions?
      #gpg --keyserver hkp://keys.gnupg.net --recv BCE9D9A42D51784F 
            # CAUTION: gpg: keyserver receive failed: Server indicated a failure
            # See https://github.com/rvm/rvm/issues/3544
      gpg --keyserver hkp://keys.gnupg.net:80 --recv-keys BCE9D9A42D51784F             
         #  gpg: key BCE9D9A42D51784F: 5 signatures not checked due to missing keys
         # gpg: key BCE9D9A42D51784F: public key "Amazon ECS <ecs-security@amazon.com>" imported
         # gpg: marginals needed: 3  completes needed: 1  trust model: pgp
         # gpg: depth: 0  valid:   2  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 2u
         # gpg: Total number processed: 1
         # gpg:               imported: 1
   else
      sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9A2FD067A2E3EF7B
   fi 
   
   if [ $? -ne 0 ]; then  # shellcheck disable=SC2181
      printf "\n>>> RETURN=%s (1 = bad/STOP, 0 = good). Exiting ... \n" "$?"
      exit
   fi
   gpg --version

printf ">>> Downloading the Amazon ECS CLI signatures ... \n"
      if [ "$PLATFORM" = "macos" ]; then
         curl -o ecs-cli.asc https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-darwin-amd64-latest.asc
      else  # linux
         curl -o ecs-cli.asc https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest.asc
      fi

printf ">>> Verifying the Amazon ECS CLI signatures ... \n"
      if [ "$PLATFORM" = "macos" ]; then
         gpg --verify ecs-cli.asc /usr/local/bin/ecs-cli
            # RESPONSE: ERROR:
            # gpg: Signature made Wed Apr 24 14:03:18 2019 MDT
            # gpg:                using RSA key DE3CBD61ADAF8B8E
            # gpg: BAD signature from "Amazon ECS <ecs-security@amazon.com>" [unknown]
         printf ">>> ERROR: BAD signature in ecs-cli.asc from Amazon ECS?  \n"

            # Expected output: (from https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html)
            # gpg: Signature made Tue Apr  3 13:29:30 2018 PDT
            # gpg:                using RSA key DE3CBD61ADAF8B8E
            # gpg: Good signature from "Amazon ECS <ecs-security@amazon.com>" [unknown]
            # gpg: WARNING: This key is not certified with a trusted signature!
            # gpg:          There is no indication that the signature belongs to the owner.
            # Primary key fingerprint: F34C 3DDA E729 26B0 79BE  AEC6 BCE9 D9A4 2D51 784F
            #      Subkey fingerprint: EB3D F841 E2C9 212A 2BD4  2232 DE3C BD61 ADAF 8B8E
      else  # linux
         gpg --verify ecs-cli.asc /usr/local/bin/ecs-cli
      fi

printf ">>> Applying execute permissions to the Binary ,,, \n"
      if [ "$PLATFORM" = "macos" ]; then
         sudo chmod +x /usr/local/bin/ecs-cli
      else  # linux
         sudo chmod +x /usr/local/bin/ecs-cli
      fi

printf ">>> Verify ecs-cli version: \n"
   ecs-cli --version

# configure the Amazon ECS CLI with your AWS credentials, an AWS region,
# and an Amazon ECS cluster name before you can use it. 

# NEXT: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_Configuration.html

### 5.1 install eksctl

install_eksctl(){
   # This is the alternatative to download directly instead of brew install:
      # Based on 0:00 into https://app.pluralsight.com/player?course=using-docker-aws&author=david-clinton&name=b874bb63-9ca2-4fa3-8d52-853c70953d8a&clip=1&mode=live
      printf "\n>>> Obtaining eksctl for latest K8S_VERSION=%s..." "$K8S_VERSION"
      # CAUTION: Get latest version from https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html
      if [ "$PLATFORM" = "macos" ]; then  # uname -a = darwin:
         curl --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
      else  # "linux"
         curl --location "https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
      fi
      if [ ! -f "/tmp/eksctl" ]; then # NOT found:
         printf ">>> eksctl file download failed. Exiting...\n"
         exit
      else
         printf ">>> Downloading eksctl.sha256 (publisher's hash) ...\n"  # 
         if [ "$PLATFORM" = "macos" ]; then  # darwin
            curl -o eksctl.sha256 "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/darwin/amd64/eksctl.sha256"
         else  # linux:
            curl -o eksctl.sha256 "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/linux/amd64/eksctl.sha256"         
         fi
         cat eksctl.sha256 
         printf "\n"
         # Comparison of hash cut out.

         # ls -al eksctl # 20.5M from ls -al /tmp/eksctl  # 
         printf "\n>>> Moving eksctl file to %s. Password required here...\n" "$BINARY_STORE_PATH"
         sudo mv /tmp/eksctl "$BINARY_STORE_PATH"  # so it can be called from anywhere.
         ls -al   "$BINARY_STORE_PATH/eksctl"
         chmod +x "$BINARY_STORE_PATH/eksctl"
      fi
}
if ! command_exists eksctl ; then  # not exist:
   if [ "$INSTALL_UTILITIES" = "no" ]; then
      printf "\n>>> eksctl not installed but INSTALL_UTILITIES=/"no/". Exiting...\n"
      exit
   fi
      # brew search No formula or cask found for "eksctl", so brew not used:
      #if [ "$PLATFORM" = "macos" ]; then
      #   echo "\n>>> Brew Installing eksctl ..."  # 
      #   brew install eksctl
      #else
         printf "\n>>> Installing eksctl ...\n"
         install_eksctl
      #fi
else  # new or reinstall:
   if [ "$INSTALL_UTILITIES" = "reinstall" ]; then
      printf "\n>>> Reinstalling eksctl ...\n"
      #if [ "$PLATFORM" = "macos" ]; then
      #   brew upgrade eksctl
      #else
         install_eksctl
      #fi
   else
      printf "\n>>> Using existing version:\n" 
   fi
fi
printf ">>> eksctl ==> $( eksctl version )\n"  # [ℹ]  version.Info{BuiltAt:"", GitCommit:"", GitTag:"0.1.38"}


### 5.2 install aws-iam-authenticator

install_aws_iam_authenticator(){
   # This is the alternatative to download directly instead of brew install:
      # Based on 3:22 into https://app.pluralsight.com/player?course=using-docker-aws&author=david-clinton&name=b874bb63-9ca2-4fa3-8d52-853c70953d8a&clip=1&mode=live
      printf "\n>>> Obtaining aws-iam-authenticator for K8S_VERSION=%s...\n" "$K8S_VERSION"
      # CAUTION: Get latest version from https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
      if [ "$PLATFORM" = "macos" ]; then  # uname -a = darwin:
         curl -o aws-iam-authenticator "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/darwin/amd64/aws-iam-authenticator"
              #% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
              #  Dload  Upload   Total   Spent    Left  Speed
              # 76 17.7M   76 13.5M    0     0   771k      0  0:00:23  0:00:17  0:00:06  748k^C
      else  # "linux"
         curl -o aws-iam-authenticator "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/linux/amd64/aws-iam-authenticator"
      fi
      if [ ! -f "aws-iam-authenticator" ]; then # NOT found:
         printf ">>> aws-iam-authenticator file download failed. Exiting...\n"
         exit
      else
         printf ">>> Downloading aws-iam-authenticator.sha256 (publisher's hash) ...\n"
         if [ "$PLATFORM" = "macos" ]; then  # darwin
            curl -o aws-iam-authenticator.sha256 "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/darwin/amd64/aws-iam-authenticator.sha256"
         else  # linux:
            curl -o aws-iam-authenticator.sha256 "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/linux/amd64/aws-iam-authenticator.sha256"
         fi
         # ls -al aws-iam-authenticator.sha256  # 
         if [ ! -f aws-iam-authenticator.sha256 ]; then # NOT found:
            printf ">>> aws-iam-authenticator.sha256 download failed!\n"
            exit
         else
            PUB_SHA256_HASH=$( cat aws-iam-authenticator.sha256 | cut -d " " -f 1 )
               # SHA256_HASH=cc35059999bad461d463141132a0e81906da6c23953ccdac59629bb532c49c83 aws-iam-authenticator
               # cut to:     cc35059999bad461d463141132a0e81906da6c23953ccdac59629bb532c49c83 aws-iam-authenticator
            printf ">>> PUB_SHA256_HASH=%s<" "$PUB_SHA256_HASH"
            rm aws-iam-authenticator.sha256

            LOC_SHA256_HASH=$( sha256sum aws-iam-authenticator  | cut -d " " -f 1 )
            printf ">>> LOC_SHA256_HASH=%s<" "$LOC_SHA256_HASH"
               # cc35059999bad461d463141132a0e81906da6c23953ccdac59629bb532c49c83 aws-iam-authenticator

            if [ "$PUB_SHA256_HASH" = "$LOC_SHA256_HASH" ]; then
               printf ">>> Hashes match!\n"
            else
               printf ">>> ERROR: Hashes do NOT match! Exiting...\n"
               exit
            fi
         fi

         printf ">>> Moving kubectl file to %s. Password required here...\n" "$BINARY_STORE_PATH"
         sudo mv kubectl "$BINARY_STORE_PATH"  # so it can be called from anywhere.
         ls -al   "$BINARY_STORE_PATH/kubectl"
         chmod +x "$BINARY_STORE_PATH/kubectl"
         printf "\n>>> Moving aws-iam-authenticator file to %s. Password required here...\n" "$BINARY_STORE_PATH"
         sudo mv aws-iam-authenticator "$BINARY_STORE_PATH"  # so it can be called from anywhere.
         ls -al   "$BINARY_STORE_PATH/aws-iam-authenticator"
         chmod +x "$BINARY_STORE_PATH/aws-iam-authenticator"
      fi
}
if ! command_exists aws-iam-authenticator ; then  # not exist:
   if [ "$INSTALL_UTILITIES" = "no" ]; then
      printf "\n>>> aws-iam-authenticator not installed but INSTALL_UTILITIES=/"no/". Exiting...\n"
      exit
   fi
      # brew version of aws-iam-authenticator displays "unversioned", so not used:
      #if [ "$PLATFORM" = "macos" ]; then
      #   echo "\n>>> Brew Installing aws-iam-authenticator ..."
      #   brew install aws-iam-authenticator
      #else
         printf "\n>>> Installing aws-iam-authenticator ...\n"
         install_aws_iam_authenticator
            # Downloading https://homebrew.bintray.com/bottles/kubernetes-cli-1.15.0.mojave.bottle.tar.gz
            # 🍺  /usr/local/Cellar/aws-iam-authenticator/0.4.0: 5 files, 31.1MB
      #fi
else  # new or reinstall:
   if [ "$INSTALL_UTILITIES" = "reinstall" ]; then
      printf "\n>>> Reinstalling aws-iam-authenticator ...\n"
      #if [ "$" = "macos" ]; then
      #   brew upgrade aws-iam-authenticator
      #else
         install_aws_iam_authenticator
      #fi
   else
      printf "\n>>> Using existing version:\n" 
   fi
fi
printf ">>> aws-iam-authenticator = $( aws-iam-authenticator version )\n"
      # {"Version":"v0.4.0","Commit":"c141eda34ad1b6b4d71056810951801348f8c367"}


### 5.3 install kubectl

# See https://matthewpalmer.net/kubernetes-app-developer/articles/guide-install-kubernetes-mac.html


install_kubectl(){
   # Kubernetes uses the kubectl command line utility for communicating with the cluster API server. 
   # This is the alternatative to download directly instead of brew install:
      # Based on 3:22 into https://app.pluralsight.com/player?course=using-docker-aws&author=david-clinton&name=b874bb63-9ca2-4fa3-8d52-853c70953d8a&clip=1&mode=live
      printf "\n>>> Obtaining kubectl for K8S_VERSION=%s...\n" "$K8S_VERSION"
      # CAUTION: Identify your cluster's Kubernetes version from Amazon S3 so you can 
      # get the corresponding version of kubectl from:
      # https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
      K8S_VERSION="1.13.7/2019-06-11"
                 # 1.12.9/2019-06-21
                 # 1.11.10/2019-06-21
                 # 1.10.13/2019-06-21
      if [ "$PLATFORM" = "macos" ]; then  # uname -a = darwin:
         curl -o kubectl "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/darwin/amd64/kubectl"
      else  # "linux"
         curl -o kubectl "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/linux/amd64/kubectl"
      fi
      if [ ! -f "kubectl" ]; then # NOT found:
         printf ">>> kubectl file download failed. Exiting...\n"
         exit
      else
         printf ">>> Downloading kubectl.sha256 (publisher's hash) ...\n" 
         if [ "$PLATFORM" = "macos" ]; then  # darwin
            curl -o kubectl.sha256 "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/darwin/amd64/kubectl.sha256"
         else  # linux:
            curl -o kubectl.sha256 "https://amazon-eks.s3-us-west-2.amazonaws.com/$K8S_VERSION/bin/linux/amd64/kubectl.sha256"
         fi
         # ls -al kubectl.sha256  # 
         if [ ! -f kubectl.sha256 ]; then # NOT found:
            printf ">>> kubectl.sha256 download failed!\n"
            exit
         else
            PUB_SHA256_HASH=$( cat kubectl.sha256 | cut -d " " -f 1 )
            printf ">>> PUB_SHA256_HASH=%s<" "$PUB_SHA256_HASH"
            rm kubectl.sha256

            LOC_SHA256_HASH=$( sha256sum kubectl  | cut -d " " -f 1 )
            printf ">>> LOC_SHA256_HASH=%s<" "$LOC_SHA256_HASH"

            if [ "$PUB_SHA256_HASH" = "$LOC_SHA256_HASH" ]; then
               echo ">>> Hashes match!"
            else
               echo ">>> ERROR: Hashes do NOT match! Exiting..."
               exit
            fi
         fi

         # ls -al kubectl # 20.5M from ls -al /tmp/kubectl  # 
         printf ">>> Moving kubectl file to %s. Password required here...\n" "$BINARY_STORE_PATH"
         sudo mv kubectl "$BINARY_STORE_PATH"  # so it can be called from anywhere.
         ls -al   "$BINARY_STORE_PATH/kubectl"
         chmod +x "$BINARY_STORE_PATH/kubectl"
      fi
}
if ! command_exists kubectl ; then  # not exist:
   if [ "$INSTALL_UTILITIES" = "no" ]; then
      printf "\n>>> kubectl not installed but INSTALL_UTILITIES=\"no\". Exiting...\n"
      exit
   fi
      # brew version of kubectl displays "unversioned", so not used:
      #if [ "$PLATFORM" = "macos" ]; then
      #   echo "\n>>> Brew Installing kubectl ..."
      #   brew install kubectl
      #else
         printf "\n>>> Installing kubectl new ...\n"
         install_kubectl
            # Downloading https://homebrew.bintray.com/bottles/kubernetes-cli-1.15.0.mojave.bottle.tar.gz
            # 🍺  /usr/local/Cellar/kubectl/0.4.0: 5 files, 31.1MB
      #fi
else  # new or reinstall:
   if [ "$INSTALL_UTILITIES" = "reinstall" ]; then
      printf "\n>>> Reinstalling kubectl ...\n"
      #if [ "$" = "macos" ]; then
      #   brew upgrade kubectl
      #else
         install_kubectl
      #fi
   else
      printf "\n>>> Using existing version:\n"
   fi
fi
printf ">>> kubectl ==> $( kubectl version --short --client )\n"  # Client Version: v1.13.7-eks-c57ff8


### 999.

if [ "$REMOVE_AT_END" = "yes" ]; then
   printf "\n>>> Removing WORK_REPO=%s in %s \n" "$WORK_REPO" "$PWD"
   rm -rf "$WORK_REPO"
fi

# per https://kubedex.com/troubleshooting-aws-iam-authenticator/
# For an automated installation the process involves pre-generating some config and certs, updating a line in the API Server manifest and installing a daemonset.

