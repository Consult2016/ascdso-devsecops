#!/bin/bash
   #sh for POSIX-compliant Bourne shell that runs cross-PACKAGE_INSTALLER

# kedro-sample-setup.sh in https://github.com/wilsonmar/DevSecOps/kedro
# This script installs what kedro needs to install,
# then clones the sample project, and runs it, all in one script,
# as described in https://wilsonmar.github.io/kedro
# But this script adds automated checks not covered in manual commands described in the tutorial.

# USAGE: This script is run by this command on MacOS/Linux Terminal:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/kedro/kedro-sample-setup.sh)"

# Coding of shell/bash scripts is described at https://wilsonmar.github.io/bash-coding
   # At this point, this script has only been written/tested on MacOS.
   # This script is idempotent because it makes a work folder and deletes it on reruns.
   # The work folder path is set in a variable so you can change it for yourself.
   # Feature flags enable deletion of 

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# CURRENT STATUS: under construction. 

set -e  # stop on error.

### 0. Set display utilities:
clear  # screen and history?

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

h2 "1. Collect parameters controlling run:"

INSTALL_UTILITIES="yes"  # no or reinstall (yes)

BINARY_STORE_PATH="/usr/local/bin"
BASHFILE="$HOME/.bash_profile"  # on Macs (alt .bashrc)
WORK_FOLDER="projects"  # as in ~/projects
WORK_REPO="kedro-sample-setup"  # by default the same name as the script file.

CONDA_ENV="py37"
GITHUB_ACCOUNT="quantumblacklabs"
GITHUB_BASE_REPO="kedro"
GITHUB_SCRIPT_REPO="kedro-examples"
TEST_PATH="$HOME/projects/kedro-sample-setup/kedro-examples/kedro-tutorial/"
SCRIPT_PATH="$HOME/projects/kedro-sample-setup/kedro-examples/kedro-tutorial/src/kedro_tutorial"

REMOVE_AT_END="no"  # yes or no (during debugging)
# TODO: Add invocation parameter override handling

# Display variables:
printf ">>> INSTALL_UTILITIES=\"%s\" (no or yes or reinstall)\n" "$INSTALL_UTILITIES"


h2 "2. OS detection to set PACKAGE_INSTALLER variable:"
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
   else
      printf ">>> What installer?  Exiting..."
      exit
   fi
elif [ "$unamestr" = 'FreeBSD' ]; then
    PACKAGE_INSTALLER='pkg'  # https://www.freebsd.org/cgi/man.cgi?query=pkg-install
elif [ "$unamestr" = 'Windows' ]; then
    PACKAGE_INSTALLER='choco'
fi

if [ "$PACKAGE_INSTALLER" = 'brew' ]; then
   printf ">>> MacOS %s \n" "$( system_profiler SPSoftwareDataType | grep "Version" )"
elif [ "$unamestr" = 'Windows' ]; then
   printf ">>> WindowsOS = \"%s\" \n"  "$( uname -a )"
else
   printf ">>> Linux OS = \"%s\" \n"  "$( uname -a )"
fi

if [ $PACKAGE_INSTALLER != 'brew' ]; then
   printf ">>> This script is not designed for %s = %s.\n" "$unamestr" "$PACKAGE_INSTALLER"
   exit
fi


h2 "3. Shell utility functions:"

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


h2 "4. Pre-requisites installation:"
command_exists() {  # in /usr/local/bin/... if installed by brew
  command -v "$@" > /dev/null 2>&1
}

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

   if ! command_exists git ; then
      printf "\n>>> Installing git client using Homebrew...\n"
      brew install git
   fi

   if ! command_exists conda ; then  # not exist:
      printf "\n>>> Before Installing anaconda, remove folders (password needed)...\n"
      sudo rm -rf /usr/local/anaconda3 
      rm -rf ~/.condarc ~/.conda ~/.continuum ~/anaconda

      printf "\n>>> brew cask install anaconda (password needed)...\n"
      brew cask install anaconda
         # anaconda was successfully installed!
      
   # else
      #brew cask reinstall anaconda
   fi
   printf "\n>>> Conda version installed ==> %s \n" "$( conda --version )"
   printf ">>> Installed to %s \n" "$( which conda )"
   # conda list --revisions   # list versions of conda.

fi  # brew


h2 "6. Get latest Kedro release tag in GitHub (using jq):"

github_latest_release() {  # generic function:
   # Based on https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
   #curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
   #grep '"tag_name":' |                                            # Get tag line
   #sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value

   # Alternative using jq utility if installed by brew:
   curl --silent "https://api.github.com/repos/$1/releases/latest" | jq -r .tag_name
}
   KEDRO_LATEST_RELEASE=$( github_latest_release "$GITHUB_ACCOUNT/$GITHUB_BASE_REPO" )
   printf "\n>>> %s latest release in GitHub ==> %s \n" "$GITHUB_ACCOUNT/$GITHUB_BASE_REPO" \
      "$KEDRO_LATEST_RELEASE"


h2 "7. Create Conda env (every time):"

RESPONSE=$( conda env list )
if [[ $RESPONSE == *"$CONDA_ENV"* ]]; then
   printf "\n>>> Conda env already created:\n%s\n" "$RESPONSE"
   conda env list

#   printf "\n>>> Removing Conda env %s ...\n%s\n" "$CONDA_ENV"
#   conda env remove -n "$CONDA_ENV"
fi

   printf "\n>>> Creating conda -n %s in /env/ at %s... \n" "$CONDA_ENV" "$CONDA_PATH"
   yes | conda create --name "$CONDA_ENV" python=3.7
   # conda create -n tf36 anaconda::tensorflow-gpu python=3.6

   #      printf "\n>>> Resetting Terminal session (requires password):\n"
   #      source ~/.bash_profile

h2 "8. Initialize Conda to Bash shell:"

printf ">>> Using shell \"%s\". \n" "$SHELL"  # "/bin/bash" even if using #!/bin/sh

   if [[ $SHELL == "/bin/bash" ]]; then
      printf ">>> Instalizing Conda to the Linux shell being used: \n" "$SHELL"
      conda init "bash"
   fi


h2 "8. Activate conda's environment on the search PATH:"

   # See https://askubuntu.com/questions/849470/how-do-i-activate-a-conda-environment-in-my-bashrc
   # See https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html

      RESPONSE="$( which conda )"  # for /usr/local/anaconda3/bin/conda"
      CONDA_PATH="${RESPONSE%/*}"  # for /usr/local/anaconda3/bin"
      printf ">>> Conda path=%s \n" "$CONDA_PATH"

      printf "\n>>> Activate conda env for Conda 4.6+ for %s \n" "$CONDA_ENV"
      #conda activate "$CONDA_ENV"
      activate "$CONDA_ENV"
         # Expected response: "$CONDA_ENV" in parenthesis, such as "(py37)"
         # See conda activate --help

printf "\n>>> Conda info: \n"   
conda info


h2 "9. install Kedro CLI inside env:"

# Based on https://github.com/quantumblacklabs/kedro
install_kedro_cli(){
         printf "\n>>> Installing kedro using pip3 ...\n" 
         # NOTE: Here "pip3" is used instead of "pip" as shown in Kendro's documentation.
         pip3 install kedro==$KEDRO_LATEST_RELEASE
}
if ! command_exists kedro ; then  # not exist:
   if [ "$INSTALL_UTILITIES" = "no" ]; then
      printf "\n>>> kedro-cli not installed but INSTALL_UTILITIES=\"no\". Exiting...\n"
      exit
   else
      install_kedro_cli
   fi
else
   if [ "$INSTALL_UTILITIES" = "reinstall" ]; then
      printf "\n>>> -Upgrading kedro using pip3 ...\n"
      pip3 install -U kedro==$KEDRO_LATEST_RELEASE
   else
      printf ">>> Using existing kedro version \n" 
   fi
fi
printf ">>> Kedro version ==> %s ...\n" "$( kedro --version )"
   # kedro, version 0.15.0
# kedro -h  # for help

which kedro
   # EXPECTED: /usr/local/bin/kedro

#   printf "\n>>> pop-up docs webpage in default browser:\n"
#   kedro docs


h2 "10. TODO: Enter Conda environment:"



h2 "11. Delete local repository if it's there (for idempotency):"

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


h2 "12. Download sample project:"

         # Because its parent folder is deleted before/after use:
         if [ ! -d "$GITHUB_ACCOUNT/$GITHUB_SCRIPT_REPO" ]; then  # folder not there
            printf "\n>>> Creating folder %s ...\n" "$GITHUB_ACCOUNT/$GITHUB_SCRIPT_REPO"
            # option: populate by git clone https://github.com/wilsonmar/golang-samples"
            git clone https://github.com/$GITHUB_ACCOUNT/$GITHUB_SCRIPT_REPO  --depth=1 
               # --depth=1 used to reduce disk space and download time if only latest master is used.
               # RESPONSE: Receiving objects: 100% (1075/1075), 2.17 MiB | 1.43 MiB/s, done.
            cd $GITHUB_SCRIPT_REPO
         fi


h2 "13. kedro test (expand screen):"
pushd "$TEST_PATH" >/dev/null
   printf "\n>>>  kedro test in %s ...\n" "$TEST_PATH"
      # By default: SCRIPT_PATH="$HOME/projects/kedro-sample-setup/kedro-examples/kedro-tutorial/src/kedro_tutorial"
   kedro test
popd >/dev/null
pwd


h2 "14. Run the script:"

pushd "$SCRIPT_PATH" >/dev/null
   printf "\n>>> kedro run script from %s \n" "$SCRIPT_PATH"
   kedro run
   # In kedro_tutorial/io: xls_local.py
   # In kedro_tutorial/nodes: pipeline.py run.py
popd >/dev/null


h2 "15. Exit Conda env and clean up:"

RESPONSE=$( conda env list )
if [[ $RESPONSE == *"$CONDA_ENV"* ]]; then
   printf "\n>>> Deactivating out Conda env %s ...\n%s\n" "$CONDA_ENV"
   conda deactivate 

   printf "\n>>> TODO: Removing Conda env %s ...\n%s\n" "$CONDA_ENV"
   conda env remove -n "$CONDA_ENV"
      # RESPONSE: Remove all packages in environment /usr/local/anaconda3/envs/py37:
fi

if [ "$REMOVE_AT_END" = "yes" ]; then
   printf "\n>>> Removing %s in %s \n" "~/$WORK_FOLDER/$WORK_REPO" "$PWD"
   rm -rf "~/$WORK_FOLDER/$WORK_REPO"

   # TODO: Remove Conda executables
   # brew cask uninstall conda
else
   printf "\n>>> REMOVE_AT_END=\"%s\", files remain in %s \n" "$REMOVE_AT_END" "$PWD"
   tree "~/$WORK_FOLDER/$WORK_REPO"
fi

# per https://kubedex.com/troubleshooting-aws-iam-authenticator/
# For an automated installation the process involves pre-generating some config and certs, updating a line in the API Server manifest and installing a daemonset.

