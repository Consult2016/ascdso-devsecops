#!/bin/bash

# mac-dock-remove.sh in https://github.com/wilsonmar/macos-install-all
# Removes alias icons on the MacOS Dock (at the bottom of the screen by default)
#    based on names provided in call argument
#    instead of manually dragging icons and dropping it outside the Dock.
#    See https://www.lifewire.com/remove-application-icons-macs-dock-2260349
# Adapted from https://www.jamf.com/jamf-nation/discussions/29939/mass-remove-dock-icons-dockutil-script

# This was tested on Mojave.
# USAGE: ./mac-dock-remove.sh "Siri News" 
#   If you're using Gmail, also:    "Contacts Mail Calendar Reminders"
#   If you're using Microsoft, also "Pages Numbers Keynote"
#   For less distractions, also     "News iTunes"

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.


### 0. Set display utilities:
# clear  # screen and history?

# Capture starting timestamp:
   start=$(date +%s)

### Set color variables (based on aws_code_deploy.sh): 
bold="\e[1m"
dim="\e[2m"
underline="\e[4m"
blink="\e[5m"
reset="\e[0m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"

h2() {
  printf "\n${bold}>>> %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
info() {
  printf "${dim}➜ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
success() {
  printf "${green}✔ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
error() {
  printf "${red}${bold}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
warnError() {
  printf "${red}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
warnNotice() {
  printf "${blue}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
note() {
  printf "\n${bold}${blue}Note:${reset} ${blue}%s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}


# Pre-requisite utility functions:
command_exists() {  # in /usr/local/bin/... if installed by brew.
  command -v "$@" > /dev/null 2>&1
}

if ! command_exists dockutil ; then  # not exist:
   #Installed at /usr/local/bin from https://github.com/kcrawford/dockutil
   brew install dockutil
   # ==> Downloading from https://codeload.github.com/kcrawford/dockutil/tar.gz/2.0.5
   # into /usr/local/bin/dockutil
fi
note ">>> dockutil --version = " $( dockutil --version )  # 2.0.5 


# Remove anything that matches keywords in the string:
REMOVE="$1"
# currentUser=$(ls -l /dev/console | awk '{print $3}')
# userHome=$(dscl . read /Users/$currentUser NFSHomeDirectory | awk '{print $2}')
note ">>> REMOVE=\"$REMOVE\" from Dock for $HOME"


#NOTE: should probably check if current user is logged in.  
# We also don't care if current user is root and would exit.  
# Will add that later. Worst case it just doesn't remove anything and may error out.  no harm, though.
function RemoveDockIcon () {
   /usr/local/bin/dockutil --remove $1 --no-restart --allhomes
}

IFS=$'\n'
apps=()
apps=($(dockutil --list --homeloc $userHome | grep $REMOVE \
	| awk -F'file:' '{print $1}' | awk 'BEGIN{ RS = "" ; FS = "\n" }{print $0}'))
info ">>> apps=\"$apps\" to be deleted ..."

# If we don't find anything, don't do anything:
if [ ! -z "$apps" ]; then
   for x in ${apps[@]}; do
      #Remove trailing spaces:
      x="$(echo -e "$x" | sed -e 's/[[:space:]]*$//')"
      success ">>> Removing Dock icon \"$x\"."
      RemoveDockIcon $x
      # TODO: Remove application too?
   done
   # Reread all plist files: https://stackoverflow.com/questions/29045965/flushing-preference-cache-with-killall-cfprefsd-causing-excessive-wake-ups-on-os
   #sudo fs_usage | grep cfprefsd 
   #killall cfprefsd 2>&1
   #killall Dock 2>&1
   exit 0
fi
# Drop to here if not exited:
error ">>> Nothing was removed."
