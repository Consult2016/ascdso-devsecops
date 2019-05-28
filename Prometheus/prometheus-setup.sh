#!/bin/bash #for bash v4

# prometheus-setup.sh in https://github.com/wilsonmar/DevSecOps/Prometheus
# This downloads and installs all the utilities related to use of Prometheus
# described at https://wilsonmar.github.io/prometheus
# When an enviornment is opened:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/Prometheus/prometheus-setup.sh)"

# This implements the LinuxAcademy.com course "DevOps Monitoring Deep Dive" by Elle.

######### Starting time stamp, OS versions, command attributes:

# For Git on Windows, see http://www.rolandfg.net/2014/05/04/intellij-idea-and-git-on-windows/
TIME_START="$(date -u +%s)"
FREE_DISKBLOCKS_START="$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6)"

# ISO-8601 plus RANDOM=$((1 + RANDOM % 1000))  # 3 digit random number.
LOG_PREFIX=$(date +%Y-%m-%dT%H:%M:%S%z)-$((1 + RANDOM % 1000))
LOGFILE="$0.$LOG_PREFIX.log"
if [ ! -z $1 ]; then  # not empty
   echo "$0 $1 starting with logging to file:"  # new file
else
   echo "$0 starting with logging to file:"   # new file
fi
echo "$LOGFILE ..." 
exit

######### Bash utility functions:

# Read first parameter from command line supplied at runtime to invoke:
MY_RUNTYPE="$1"
if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then # variable made lower case.
   echo "MY_RUNTYPE=\"$MY_RUNTYPE\" means all packages here will be upgraded ..." >>$LOGFILE
fi


######### Git functions:


# Based on https://gist.github.com/dciccale/5560837
# Usage: GIT_BRANCH=$(parse_git_branch)$(parse_git_hash) && echo ${GIT_BRANCH}
# Check if branch has something pending:
function git_parse_dirty() {
   git diff --quiet --ignore-submodules HEAD 2>/dev/null; [ $? -eq 1 ] && echo "*"
}
# Get the current git branch (using git_parse_dirty):
function git_parse_branch() {
   git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(git_parse_dirty)/"
}
# Get last commit hash prepended with @ (i.e. @8a323d0):
function git_parse_hash() {
   git rev-parse --short HEAD 2> /dev/null | sed "s/\(.*\)/@\1/"
}


######### Bash function definitions:


# Add function to read in string and email, and return a KEY found for that email.
# GPG_MAP_MAIL2KEY associates the key and email in an array
function GPG_MAP_MAIL2KEY(){
KEY_ARRAY=($(echo "$str" | awk -F'sec   rsa2048/|2018* [SC]' '{print $2}' | awk '{print $1}'))
# Remove trailing blank: KEY="$(echo -e "${str}" | sed -e 's/[[:space:]]*$//')"
MAIL_ARRAY=($(echo "$str" | awk -F'<|>' '{print $2}'))
#Test if the array count of the emails and the keys are the same to avoid conflicts
if [ ${#KEY_ARRAY[@]} == ${#MAIL_ARRAY[@]} ]; then
   declare -A KEY_MAIL_ARRAY=()
   for i in "${!KEY_ARRAY[@]}"
   do
      KEY_MAIL_ARRAY[${MAIL_ARRAY[$i]}]=${KEY_ARRAY[$i]}
   done
   #Return key matching email passed into function
   echo "${KEY_MAIL_ARRAY[$1]}"
else
   #exit from script if array count of emails and keys are not the same
   exit 1 && fancy_echo "Email count and Key count do not match"
fi
}

function VIRTUALBOX_INSTALL(){
   if [ ! -d "/Applications/VirtualBox.app" ]; then 
   #if ! command -v virtualbox >/dev/null; then  # /usr/local/bin/virtualbox
      fancy_echo "Installing virtualbox ..."
      brew cask install --appdir="/Applications" virtualbox
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "virtualbox upgrading ..."
         # virtualbox --version
         brew cask upgrade virtualbox
      else
         fancy_echo "virtualbox already installed." >>$LOGFILE
      fi
   fi
   #echo -e "\n$(virtualbox --version)" >>$LOGFILE

   if [ ! -d "/Applications/Vagrant Manager.app" ]; then 
      fancy_echo "Installing vagrant-manager ..."
      brew cask install --appdir="/Applications" vagrant-manager
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "vagrant-manager upgrading ..."
         brew cask upgrade vagrant-manager
      else
         fancy_echo "vagrant-manager already installed." >>$LOGFILE
      fi
   fi

######### OSX configuration:


fancy_echo "Configure OSX Finder to show hidden files too:" >>$LOGFILE
defaults write com.apple.finder AppleShowAllFiles YES
# NOTE: Additional config dotfiles for Mac?
# NOTE: See osx-init.sh in https://github.com/wilsonmar/DevSecOps/osx-init
#       installs other programs on Macs for developers.


# Ensure Apple's command line tools (such as cc) are installed by node:
if ! command -v cc >/dev/null; then
   fancy_echo "Installing Apple's xcode command line tools (this takes a while) ..."
   xcode-select --install 
   # Xcode installs its git to /usr/bin/git; recent versions of OS X (Yosemite and later) ship with stubs in /usr/bin, which take precedence over this git. 
fi
pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep version
   # Tools_Executables | grep version
   # version: 9.2.0.0.1.1510905681


######### bash completion:

echo -e "$(bash --version | grep 'bash')" >>$LOGFILE

# BREW_VERSION="$(brew --version)"
# TODO: Completion of bash commands on MacOS:
# See https://kubernetes.io/docs/tasks/tools/install-kubectl/#on-macos-using-bash
# Also see https://github.com/barryclark/bashstrap

# TODO: Extract 4 from $BASH_VERSION
      # GNU bash, version 4.4.19(1)-release (x86_64-apple-darwin17.3.0)

## or, if running Bash 4.1+
#brew install bash-completion@2
## If running Bash 3.2 included with macOS
#brew install bash-completion

exit

# Create a system user for Prometheus:
 sudo useradd --no-create-home --shell /bin/false prometheus

# Create the directories in which we'll be storing our configuration files and libraries:
 sudo mkdir /etc/prometheus
 sudo mkdir /var/lib/prometheus

# Set the ownership of the /var/lib/prometheus directory:
 sudo chown prometheus:prometheus /var/lib/prometheus

# Pull down the tar.gz file from the Prometheus downloads page:
 cd /tmp/
 wget https://github.com/prometheus/prometheus/releases/download/v2.7.1/prometheus-2.7.1.linux-amd64.tar.gz

# Extract the files:
 tar -xvf prometheus-2.7.1.linux-amd64.tar.gz

# Move the configuration file and set the owner to the prometheus user:
 sudo mv console* /etc/prometheus
 sudo mv prometheus.yml /etc/prometheus
 sudo chown -R prometheus:prometheus /etc/prometheus

# Move the binaries and set the owner:
 sudo mv prometheus /usr/local/bin/
 sudo mv promtool /usr/local/bin/
 sudo chown prometheus:prometheus /usr/local/bin/prometheus
 sudo chown prometheus:prometheus /usr/local/bin/promtool

# Create the service file:
 sudo $EDITOR /etc/systemd/system/prometheus.service

# Concatenate prometheus-setup.txt from github.com/wilsonmar/DevSecOps/Prometheus:
   cat /etc/systemd/system/prometheus.service << https://github.com/wilsonmar/DevSecOps/Prometheus
# Save and exit.

# Reload systemd:
 sudo systemctl daemon-reload

# Start Prometheus, and make sure it automatically starts on boot:
 sudo systemctl start prometheus
 sudo systemctl enable prometheus

# Visit Prometheus in your web browser at PUBLICIP:9090.
   


######### bash.profile configuration:


BASHFILE=$HOME/.bash_profile  # on Macs

# if ~/.bash_profile has not been defined, create it:
if [ ! -f "$BASHFILE" ]; then #  NOT found:
   fancy_echo "Creating blank \"${BASHFILE}\" ..." >>$LOGFILE
   touch "$BASHFILE"
   echo "PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" >>"$BASHFILE"
   # El Capitan no longer allows modifications to /usr/bin, and /usr/local/bin is preferred over /usr/bin, by default.
else
   LINES=$(wc -l < "${BASHFILE}")
   fancy_echo "\"${BASHFILE}\" already created with $LINES lines." >>$LOGFILE
   fancy_echo "Backing up file $BASHFILE to $BASHFILE-$LOG_PREFIX.bak ..."  >>$LOGFILE
   cp "$BASHFILE" "$BASHFILE-$LOG_PREFIX.bak"
fi



######### Disk space consumed:


FREE_DISKBLOCKS_END=$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6) 
DIFF=$(((FREE_DISKBLOCKS_START-FREE_DISKBLOCKS_END)/2048))
echo -e "\n   $DIFF MB of disk space consumed during this script run." >>$LOGFILE
# 380691344 / 182G = 2091710.681318681318681 blocks per GB
# 182*1024=186368 MB
# 380691344 / 186368 G = 2042 blocks per MB

TIME_END=$(date -u +%s);
DIFF=$((TIME_END-TIME_START))
MSG="End of script after $((DIFF/60))m $((DIFF%60))s seconds elapsed."
fancy_echo "$MSG"
echo -e "\n$MSG" >>$LOGFILE
