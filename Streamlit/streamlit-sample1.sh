#!/bin/bash

# This script https://streamlit.io/
# Tested on macOS Mojave 10.14 
# Design is at https://wilsonmar.github.io/python-api-flask
# Copyright MIT license.
# See https://medium.com/swlh/part-1-will-streamlit-kill-off-flask-5ecd75f879c8

# USAGE TEST: ./find_replace1.sh  -u https://  -v
# USAGE PROD: ./find_replace1.sh -v -p -a -u "git@githuben.intranet.mckinsey.com:product-tooling/app-dtportal-backend.git" 



# This was tested on macOS Mojava and CentOS 7.7 running under dzoz admin permissions.
# See the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

### 0. Set display utilities:

clear  # screen (but not history)

#set -eu pipefail  # pipefail counts as a parameter
# set -x to show commands for specific issues.
# set -o nounset
# set -e  # to end if 

# Capture starting timestamp and display no matter how it ends:
EPOCH_START="$(date -u +%s)"  # such as 1572634619
FREE_DISKBLOCKS_START="$(df -k . | cut -d' ' -f 6)"  # 910631000 Available

trap this_ending EXIT
trap this_ending INT QUIT TERM
this_ending() {
   echo "_"
   EPOCH_END=$(date -u +%s);
   DIFF=$((EPOCH_END-EPOCH_START))

   FREE_DISKBLOCKS_END="$(df -k . | cut -d' ' -f 6)"
   DIFF=$(((FREE_DISKBLOCKS_START-FREE_DISKBLOCKS_END)))
   MSG="End of script after $((DIFF/360)) minutes and $DIFF bytes disk space consumed."
   #   info 'Elapsed HH:MM:SS: ' $( awk -v t=$beg-seconds 'BEGIN{t=int(t*1000); printf "%d:%02d:%02d\n", t/3600000, t/60000%60, t/1000%60}' )
   success "$MSG"
   #note "$FREE_DISKBLOCKS_START to 
   #note "$FREE_DISKBLOCKS_END"
}
sig_cleanup() {
    trap '' EXIT  # some shells call EXIT after the INT handler.
    false # sets $?
    this_ending
}


### Set color variables (based on aws_code_deploy.sh): 
bold="\e[1m"
dim="\e[2m"
underline="\e[4m"
blink="\e[5m"
reset="\e[0m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"
cyan="\e[36m"

h2() {     # heading
  printf "\n${bold}>>> %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
info() {   # output on every run
  printf "${dim}\n➜ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
note() {   # if [ "$RUN_VERBOSE" = true ]; then
  printf "${bold}${cyan} ${reset} ${cyan}%s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
success() {
  printf "${green}✔ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
error() {
  printf "${red}${bold}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
warnNotice() {
  printf "${cyan}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}
warnError() {
  printf "${red}✖ %s${reset}\n" "$(echo "$@" | sed '/./,$!d')"
}

# Check what operating system is used now.
if [ "$(uname)" == "Darwin" ]; then  # it's on a Mac:
   OS_TYPE="macOS"
elif [ -f "/etc/centos-release" ]; then
   OS_TYPE="CentOS"  # for yum
elif [ -f $( "lsb_release -a" ) ]; then  # TODO: Verify this works.
   OS_TYPE="Ubuntu"  # for apt-get
else 
   error "Operating system not anticipated. Please update script. Aborting."
   exit 0
fi
HOSTNAME=$( hostname )
info "OS_TYPE=$OS_TYPE on hostname=$HOSTNAME."


# h2 "STEP 1 - Ensure run variables are based on arguments or defaults ..."
args_prompt() {
   echo "This shell script edits a file (using sed) to trigger CI/CD upon git push."
   echo "USAGE EXAMPLE during testing (minimal inputs using defaults):"
   #echo "   ./find_replace1.sh -f \"from text\" -t \"to text\" -u \"URL\" -v -a -d"
   echo "OPTIONS:"
   echo "   -f       list of files to process"
   echo "   -v       to run verbose (list space use and each image to console)"
   echo "   -a       for actual (not --dry-run) delete & garbage collection"
   echo "   -d       to delete files after run (to save disk space)"
   echo "   -p       to run in production (default is to run in non-prod)"
 }
if [ $# -eq 0 ]; then  # display if no paramters are provided:
   args_prompt
fi
exit_abnormal() {                              # Function: Exit with error.
  args_prompt
  exit 1
}
# Defaults:
RUNTYPE="upgrade"
RUN_ACTUAL=true  # false as dry run is default.  TODO: Add parse of command parameters
RUN_DELETE_AFTER=false
USER_EMAIL="wilsonmar@gmail.com"
BUILD_PATH="$HOME/gits"
RESTART_DOCKER=false
CURRENT_IMAGE="helloworld-streamlit"

while test $# -gt 0; do
  case "$1" in
    -h|-H|--help)
      args_prompt
      exit 0
      ;;
    -R)
      export RESTART_DOCKER=true
      shift
      ;;
    -r*)
      shift
      export RUNTYPE=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    -u)
      shift
      export USER_EMAIL=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    -v)
      export RUN_VERBOSE=true
      shift
      ;;
    -a)
      export RUN_ACTUAL=true
      shift
      ;;
    -p)
      export RUN_PROD=true  # NPD = non-production default
      shift
      ;;
    -d)
      export RUN_DELETE_AFTER=true
      shift
      ;;
    *)
      error "Parameter \"$1\" not recognized. Aborting."
      exit 0
      break
      ;;
  esac
done

command_exists() {  # newer than which {command}
  command -v "$@" > /dev/null 2>&1
}

#################

h2 "From $0 in $PWD"

#install_homebrew() {
   if ! command_exists brew ; then  # not exist:
       RUBY_VERSION="$(ruby --version)"
       h2 "1.2 Installing homebrew using Ruby $RUBY_VERSION ..." 
       ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
       brew tap caskroom/cask
   else
       # Upgrade if run-time attribute contains "upgrade":
       if [[ "${RUNTYPE}" == *"update"* ]]; then
          BREW_VERSION="$(brew --version | grep "Homebrew ")"
          h2 "1.2 Brew upgrading $BREW_VERSION ..." 
          brew update 
       fi
   fi
   echo "$(brew --version)"
#}

#install_docker() {
   if ! command_exists docker ; then
       h2 "2.3 Installing docker ..." 
       brew install docker
   else
       if [[ "${RUNTYPE}" == *"update"* ]]; then
          h2 "2.3 Upgrading docker ..." 
          brew upgrade docker
       fi
   fi
   echo "$(docker -v)"  # Docker version 19.03.5, build 633a0ea
#}


install_python() {
   echo "$(python3 --version)"
}

install_venv() {
   if ! command_exists virtualenv ; then
       h2 "2.3 Installing virtualenv ..." 
       pip install virtualenv
   else
       if [[ "${RUNTYPE}" == *"update"* ]]; then
          h2 "2.3 Upgrading virtualenv ..." 
          # ??? virtualenv
       fi
   fi
   echo "$(virtualenv ???)"
}


#install_streamlit() {
   if ! command_exists streamlit ; then
       h2 "2.3 Installing pip streamlit ..." 
       pip install streamlit
       # Run this within virtualenv or see:
       # ERROR: boto3 1.10.45 has requirement botocore<1.14.0,>=1.13.45, but you'll have botocore 1.13.28 which is incompatible.
       # Installs to:
       #     /usr/local/bin/streamlit
       #     /usr/local/bin/streamlit.cmd
       #     /usr/local/lib/python3.7/site-packages/streamlit-0.52.2.dist-info/*
       #     /usr/local/lib/python3.7/site-packages/streamlit/*
   else
       # Upgrade if run-time attribute contains "upgrade":
       if [[ "${RUNTYPE}" == *"update"* ]]; then
          STREAMLIT_VERSION="$( streamlit version )"
          h2 "1.2 Upgrading from $STREAMLIT_VERSION ..." 
          pip install streamlit --upgrade
       fi
   fi
   echo "$(streamlit version)"  # Streamlit, version 0.52.2
#}

build_hello() {
   h2 "Streamlit hello command generates and brings up http://localhost:8501 on your default browser."
   streamlit hello <<-EOF
$USER_EMAIL
EOF

}

      if [ ! -d "$BUILD_PATH" ]; then
         h2 "1.2 Creating BUILD_PATH "$BUILD_PATH" ..." 
         cd
         mkdir -p "$BUILD_PATH"
         cd "$BUILD_PATH"
      # else TODO: Delete for idempotency
      fi

      if [ ! -d "webApps" ]; then
         h2 "1.2 Cloning ..." 
         git clone https://github.com/bcottman/webApps.git
         cd WebApps
         pwd
      # else
         # TODO: Delete for idempotency?
      fi


   if [ "$RESTART_DOCKER" = false ]; then
      note "Not restarting Docker ..."
   else
      h2 "1.2 Restarting Docker ..." 
      # Restart Docker to avoid:
      # Cannot connect to the Docker daemon at unix:///var/run/docker.sock. 
      # Is the docker daemon running?.
      killall com.docker.osx.hyperkit.linux
   fi

# https://sudo-bmitch.github.io/presentations/dc2018/faq-stackoverflow-lightning.html#1

h2 "Remove Docker image running from previous run ..."

# List all stopped containers:
   docker container ls -a --filter status=exited --filter status=created

# Remove all stopped containers:
   docker container prune --force

h2 "Stop active containers ..."
   # See https://linuxize.com/post/how-to-remove-docker-images-containers-volumes-and-networks/
   ACTIVE_CONTAINER=$( docker container ls -aq )
   if [ ! -z "$ACTIVE_CONTAINER" ]; then  # var blank
      # note "$ACTIVE_CONTAINER is the active container"
      docker container stop $ACTIVE_CONTAINER
      docker ps  # should not list anything now.
   fi

h2 "Build Streamlit Docker image from Python 3.7 (takes several minutes first time) ..."

   cd webApps/Streamlit/helloWorld
   pwd
   docker build -f Dockerfile -t "$CURRENT_IMAGE":latest .

   # build from registry:
   # docker build --cache-from my_image ...



if [ "$RUN_ACTUAL" = false ]; then
   echo ">>> Dry run default. Not run."
else
   h2 "-actual run Streamlit Docker image ..."
   # Format: docker ${docker_args} run ${run_args} image ${cmd}
   # docker run -it --rm -p 8888:8888 -v "$(pwd)"/../src:/src -v "$(pwd)"/../data:/data -w /src supervisely_anpr bash
   RESPONSE="$( docker run --rm -p 8501:8501 $CURRENT_IMAGE )"
   info "$RESPONSE"
   # You can now view your Streamlit app in your browser.
   # Network URL: locahost:8501
fi


exit


# docker: Error response from daemon: driver failed programming external connectivity on endpoint 
# quirky_sanderson (8ef9677560e80f482beff4c7f4f962e0705ccbd82e16df759978080497b47a82): Bind for 0.0.0.0:8501 failed: port is already allocated.

# mount the volume 
# docker run -d -p 80:80 -v $PWD:/usr/share/nginx/html nginx"



   if [ "$RUN_DELETE_AFTER" = false ]; then
      echo ">>> Deletion after push not specified."
   else  # if true:
      echo ">>> Deleting cloned folder ${TARGET_REPO} to save disk space:"
      cd ..
      rm -rf "${TARGET_REPO}"
   fi

popd # to undo pushd
echo ">>> Back at $PWD"
echo ">>> Now open browser to see new job in GoCD."
   # https://amdc-devegos-lx01.amdc.mckinsey.com:8154/go/tab/pipeline/history/frontend-build
   # https://amdc-devegos-lx01.amdc.mckinsey.com:8154/go/tab/pipeline/history/dtportal-backend-build
# Make sure the app still runs fine:
   # https://home.intranet.mckinsey.com/dtportal/
# Verify the tag created in the Docker Registry at:
   # ls /data/registry/docker/registry/v2/repositories/dtportal/nodejs-backend/_manifests/tags/ -al   