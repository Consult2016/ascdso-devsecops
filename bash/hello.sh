#!/usr/bin/env bash

# install.sh in https://githuben.mckinsey.com/wilsonmar/dev-bootcamp
# This downloads and installs all the utilities, then verifies.
# After getting into the Cloud9 enviornment and cd to folder, copy this line:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/bash/hello.sh)"
# bash -c "$(curl -fsSL https://githuben.intranet.mckinsey.com/raw/Wilson-Mar/dev-bootcamp/master/hello.sh)"

# See https://github.com/wilsonmar/git-utilities/blob/master/README.md
# Based on https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup
# and https://git-scm.com/docs/git-config
# and https://medium.com/my-name-is-midori/how-to-prepare-your-fresh-mac-for-software-development-b841c05db18
# https://www.bonusbits.com/wiki/Reference:Mac_OS_DevOps_Workstation_Setup_Check_List
# More at https://github.com/thoughtbot/laptop/blob/master/mac
# TOC: Functions (GPG_MAP_MAIL2KEY, Python, Python3, Java, Node, Go, Docker) > 

# Starting: Secrets > XCode > XCode/Ruby > bash.profile > Brew > gitconfig > gitignore > Git web browsers > p4merge > linters > Git clients > git users > git tig > BFG > gitattributes > Text Editors > git [core] > git coloring > rerere > prompts > bash command completion > git command completion > Git alias keys > Git repos > git flow > git hooks > Large File Storage > gcviewer, jmeter, jprofiler > code review > git signing > Cloud CLI/SDK > Selenium > SSH KeyGen > SSH Config > Paste SSH Keys in GitHub > GitHub Hub > dump contents > disk space > show log
# set -o nounset -o pipefail -o errexit  # "strict mode"
# set -u  # -uninitialised variable exits script.
# set -e  # -exit the script if any statement returns a non-true return value.
# set -a  # Mark variables which are modified or created for export. Each variable or function that is created or modified is given the export attribute and marked for export to the environment of subsequent commands. 
# set -v  # -verbose Prints shell input lines as they are read.
IFS=$'\n\t'  # Internal Field Separator for word splitting is line or tab, not spaces.
# shellcheck disable=SC2059
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT
trap cleanup EXIT
trap sig_cleanup INT QUIT TERM

function fancy_echo() {
  local fmt="$1"; shift
  # shellcheck disable=SC2059
  printf "\\n>>> $fmt\\n" "$@"
}
# From https://gist.github.com/somebox/6b00f47451956c1af6b4
function echo_ok { echo -e '\033[1;32m'"$1"'\033[0m'; }
function echo_warn { echo -e '\033[1;33m'"$1"'\033[0m'; }
function echo_error  { echo -e '\033[1;31mERROR: '"$1"'\033[0m'; }


######### Starting time stamp, OS versions, command attributes:


# For Git on Windows, see http://www.rolandfg.net/2014/05/04/intellij-idea-and-git-on-windows/
TIME_START="$(date -u +%s)"
FREE_DISKBLOCKS_START="$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6)"
PUBLIC_IP="$( curl -s ifconfig.me )"
THISPGM="mac-install-all.sh"
# ISO-8601 plus RANDOM=$((1 + RANDOM % 1000))  # 3 digit random number.
LOG_DATETIME=$(date +%Y-%m-%dT%H:%M:%S%z)-$((1 + RANDOM % 1000))
LOGFILE="$HOME/$THISPGM.$LOG_DATETIME.log"
echo "$THISPGM starting with logging to file:" >$LOGFILE  # new file
echo $LOGFILE >>$LOGFILE
clear  # screen
echo $LOGFILE  # to screen

RUNTYPE=""  # value to be replaced with definition in secrets.sh.
#bar=${RUNTYPE:-none} # :- sets undefine value. See http://redsymbol.net/articles/unofficial-bash-strict-mode/

fancy_echo "sw_vers ::"     >>$LOGFILE
 echo "$(sw_vers)"       >>$LOGFILE
 echo "uname -a : $(uname -a)"      >>$LOGFILE

function cleanup() {
    err=$?
    echo "At cleanup() LOGFILE=$LOGFILE"
    #open -a "Atom" $LOGFILE
    open -e $LOGFILE  # open for edit using TextEdit
    #rm $LOGFILE
    trap '' EXIT INT TERM
    exit $err 
}
cleanup2() {
    err=$?
    echo "At cleanup2() LOGFILE=$LOGFILE"
    # pico $LOGFILE
    trap '' EXIT INT TERM
    exit $err 
}
sig_cleanup() {
    echo "At sig_cleanup() LOGFILE=$LOGFILE"
    trap '' EXIT # some shells will call EXIT after the INT handler
    false # sets $?
    cleanup
}

#Mandatory:
   # Ensure Apple's command line tools (such as cc) are installed by node:
   if ! command -v cc >/dev/null; then
      fancy_echo "Installing Apple's xcode command line tools (this takes a while) ..."
      xcode-select --install 
      # Xcode installs its git to /usr/bin/git; recent versions of OS X (Yosemite and later) ship with stubs in /usr/bin, which take precedence over this git. 
   fi
   xcode-select --version  >>$LOGFILE
   # XCode version: https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man1/pkgutil.1.html
   # pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep version
   # Tools_Executables | grep version
   # version: 9.2.0.0.1.1510905681
   # TODO: https://gist.github.com/tylergets/90f7e61314821864951e58d57dfc9acd


######### bash.profile configuration:


BASHFILE="$HOME/.bash_profile"  # on Macs
# if ~/.bash_profile has not been defined, create it:
if [ ! -f "$BASHFILE" ]; then #  NOT found:
   fancy_echo "Creating blank \"${BASHFILE}\" ..." >>$LOGFILE
   touch "$BASHFILE"
   echo "PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" >>"$BASHFILE"
   # El Capitan no longer allows modifications to /usr/bin, and /usr/local/bin is preferred over /usr/bin, by default.
else
   LINES=$(wc -l < "${BASHFILE}")
   fancy_echo "\"${BASHFILE}\" already created with $LINES lines." >>$LOGFILE
   echo "Backing up file $BASHFILE to $BASHFILE-$LOG_DATETIME.bak ..."  >>$LOGFILE
   cp "$BASHFILE" "$BASHFILE-$LOG_DATETIME.bak"
fi

function BASHFILE_EXPORT() {
   name=$1
   value=$2

   if grep -q "export $name=" "$BASHFILE" ; then    
      fancy_echo "$name alias already in $BASHFILE" >>$LOGFILE
   else
      fancy_echo "Adding $name in $BASHFILE..."
                  "$name='$value'" 
      echo "export $name='$value'" >>"$BASHFILE"
   fi
}
# BASHFILE_EXPORT "HELLO" "/usr/local/bin"


######### bash completion:


fancy_echo "$(bash --version | grep 'bash')" >>$LOGFILE

# See https://kubernetes.io/docs/tasks/tools/install-kubectl/#on-macos-using-bash
# Also see https://github.com/barryclark/bashstrap

# TODO: Extract 4 from $BASH_VERSION
      # GNU bash, version 4.4.19(1)-release (x86_64-apple-darwin17.3.0)

## or, if running Bash 4.1+
#brew install bash-completion@2
## If running Bash 3.2 included with macOS
#brew install bash-completion
#      brew info atom >>$LOGFILE
 #     brew list atom >>$LOGFILE



######### Disk space consumed:


FREE_DISKBLOCKS_END=$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6) 
DIFF=$(((FREE_DISKBLOCKS_START-FREE_DISKBLOCKS_END)/2048))
fancy_echo "$DIFF MB of disk space consumed during this script run." >>$LOGFILE
# 380691344 / 182G = 2091710.681318681318681 blocks per GB
# 182*1024=186368 MB
# 380691344 / 186368 G = 2042 blocks per MB

TIME_END=$(date -u +%s);
DIFF=$((TIME_END-TIME_START))
MSG="End of script $THISPGM after $((DIFF/60))m $((DIFF%60))s seconds elapsed."
fancy_echo "$MSG"
echo -e "\n$MSG" >>$LOGFILE

say "script ended."  # through speaker
#END