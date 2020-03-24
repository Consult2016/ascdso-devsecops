#!/usr/bin/env bash

# File osx-init.sh from https://github.com/wilsonmar/DevSecOps/
# based on https://github.com/sobolevn/dotfiles/blob/master/Brewfile
# Let me know you're using this - wilsonmar@gmail.com

# To run this, open a Terminal window and manually:
#   chmod +x osx-init.sh
#   ./osx-init.sh
#
# Installed: XCode > Homebrew > git > ruby, node > npm > apm

# brew installs to /usr/local/Cellar/...

fancy_echo() {
  local fmt="$1"; shift
  # shellcheck disable=SC2059
  printf "\n>>> $fmt\n" "$@"
}

#if [[ $EUID -ne 0 ]]; then
#   echo “Run using sudo "$0" to avoid repeat entry of passwords.“ 1>&2
#   exit 1
#fi

fancy_echo "Boostrapping ..."
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT
#set -e
#set -o xtrace  # for debugging this bash shell script.


# From https://gist.github.com/somebox/6b00f47451956c1af6b4
function echo_ok { echo -e '\033[1;32m'"$1"'\033[0m'; }
function echo_warn { echo -e '\033[1;33m'"$1"'\033[0m'; }
function echo_error  { echo -e '\033[1;31mERROR: '"$1"'\033[0m'; }

# This script is like https://www.bonusbits.com/wiki/Reference:Mac_OS_DevOps_Workstation_Setup_Check_List

# Ensure Apple's command line tools (such as cc) are installed:
if ! command -v cc >/dev/null; then
  fancy_echo "Installing Apple's xcode command line tools ..."
  xcode-select --install 
else
  fancy_echo "Xcode already installed. Skipping."
fi


fancy_echo "Configure Terminal to show all files:"
defaults write com.apple.finder AppleShowAllFiles YES


brew install freetype  # http://www.freetype.org to render fonts
fancy_echo "Install and Set San Francisco as System Font ..."
ruby -e "$(curl -fsSL https://raw.github.com/wellsriley/YosemiteSanFranciscoFont/master/install)"


## Networking
# See https://serverfault.com/questions/102416/iptables-equivalent-for-mac-os-x
# WaterRoof or Flying Buttress to iptables


## ~/.bash_profile
# Add $PATH
# TODO: Check if file is present: ~/.bash_profile


## TODO: Install homebrew using whatever Ruby is installed.

#brew tap caskroom/cask
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

brew analytics off

#fancy_echo "Brew Doctor before starting ..."
#brew doctor

# TODO: Define proxy:
# See https://www.predix.io/resources/tutorials/tutorial-details.html?tutorial_id=1565


# brew cask install --appdir="/Applications" git
# brew cask install --appdir="/Applications" github
brew cask install --appdir="/Applications" sourcetree

# fancy_echo "Installing Bluetooth ..."
# 0. Check "Show Bluetooth in menu bar".

## Battery percentage
# http://osxdaily.com/2016/12/13/see-battery-life-remaining-macos-sierra/

#fancy_echo "Installing Bash 4 ..."
#brew install bash
   # In order to use this build of bash as your login shell,
   # it must be added to /etc/shells.

fancy_echo "Installing basic Linux utilities ..."
brew cask install --appdir="/Applications" iterm2
brew install wget
brew install tree
brew install htop
# https://github.com/caskroom/homebrew-cask/blob/master/Casks/the-unarchiver.rb
# brew cask install --appdir="/Applications" the-unarchiver  

# fancy_echo "Installing File transfer:"
#brew cask install --appdir="/Applications" filezilla  ## config file too???
   # TODO: Download Filezilla config file.
brew install free-download-manager

fancy_echo "GNU utilities to sign ..."
#brew install gpg # https://geoff.greer.fm/ag/
#brew install gpg1
#brew install pinentry-mac
brew install openssl
    # openssl version  # OpenSSL 0.9.8zh 14 Jan 2016
#brew install gnu-sed # sed -i s/your-bucket-name/$DEVSHELL_PROJECT_ID/ config.py

## Install GNU core utilities (those that come with OS X are outdated)
# brew tap homebrew/dupes
brew install coreutils
#brew install gnu-sed --with-default-names

#brew install gnu-tar --with-default-names
# rar from winrar
brew cask install --appdir="/Applications" keka      # for unzipping compressed zip, tar.gz, etc.

#brew install gnu-indent --with-default-names
#brew install gnu-which --with-default-names
#brew install gnu-grep --with-default-names

#brew install findutils  --with-default-names

brew cask install --appdir="/Applications" powershell
    # see https://docs.microsoft.com/en-us/powershell/scripting/setup/installing-powershell-core-on-macos-and-linux?view=powershell-6

####### Networking:

brew cask install --appdir="/Applications" little-snitch  # makes Internet connections visible $45: https://www.obdev.at/products/littlesnitch/download.html
# To analyze network traffic and files (from https://www.wireshark.org/)
#brew install wireshark
#brew cask install --appdir="/Applications" wireshark
    # password required here.


# fancy_echo "Installing Cloud File Strage apps:"
# TODO: brew cask install --appdir="/Applications" box
# brew cask install --appdir="/Applications" dropbox
# brew cask install --appdir="/Applications" google drive (backup and sync) ???
# Amazon Drive storage
# dattodrive free storage
# brew cask install --appdir="/Applications" transmission. # Bittorrant https://transmissionbt.com/

# Compare text files:
# brew cask install --appdir="/Applications" kaleidoscope  # compare text
brew cask install --appdir="/Applications" p4merge 
# kdiff3 # https://www.slant.co/options/4399/alternatives/~kdiff3-alternatives
# brew install colordiff
# brew install irssi
# brew install links

fancy_echo "Installing languages:"
#brew cask install --appdir="/Applications" java
   java -version

brew install maven
    mvn -v

brew install gcmeter
brew install jmeter


brew install gradle
    # gradle --version
brew install grunt-cli

brew install yarn --ignore-dependencies
    # 1.3.2

# brew install carthage # to build  https://github.com/Carthage/Carthageexit 9 

brew install bower  # installer for GUI

brew install http-server
#brew install express
# from Walmart Labs

# TODO: Ruby comes with MacOS:
#brew install ruby
ruby -v  # ruby 2.5.0p0 (2017-12-25 revision 61468) [x86_64-darwin16]

#brew install nativescript # https://www.nativescript.org/blog/installing-nativescript-on-windows

#brew install elm
#brew install haskell-stack
#brew install idris

#brew tap homebrew/science
#brew install r

#brew install python
   # python -V  # 2.7
brew install python3
#pip install --upgrade flake8
#virtualenv
brew cask install --appdir="/Applications" anaconda
   # To use anaconda, add the /usr/local/anaconda3/bin directory to your PATH environment 
   # variable, eg (for bash shell):
  export PATH=/usr/local/anaconda3/bin:"$PATH"
#brew doctor fails run here due to /usr/local/anaconda3/bin/curl-config, etc.
#Cask anaconda installs files under "/usr/local". The presence of such
#files can cause warnings when running "brew doctor", which is considered
#to be a bug in Homebrew-Cask.

# Using Python - # see https://djangoforbeginners.com/
pip3 install -g jupyter


#fancy_echo "Installing Mac Productivity …:"
#brew cask install --appdir="/Applications" alfred  # https://www.alfredapp.com/
  
# brew install the_silver_searcher. # https://github.com/ggreer/the_silver_searcher


if ! command -v node >/dev/null; then
    fancy_echo "node and npm ..."
    brew install node
else
    node -v  #v9.5.0
fi

if ! command -v npm >/dev/null; then
   brew install npm  # node package manager 
else
    npm -v # 5.6.0
fi
#npm install --global nodemon -g
#npm install --global gulp-cli  #https://www.taniarascia.com/getting-started-with-gulp/
#npm  # https://gist.github.com/codeinthehole/26b37efa67041e1307db


## Notes and secrets:
# http://mike.kaply.com
# is a goldmine for configuring Firefox by the author of CCK and CCK2
#https://stackoverflow.com/questions/37728865/install-webextensions-on-firefox-from-the-command-line
#AgileBits
brew cask install --appdir="/Applications" 1password
# brew install lastpass-cli
# brew cask install --appdir="/Applications" keepassx

brew cask install --appdir="/Applications" kindle    # 32-bit Installed to "~/Applications" by default.
brew cask install --appdir="/Applications" evernote  # Installed to "~/Applications" by default.
# Microsoft OneNote
# Amphetamine for Mac
# brew cask install --appdir="/Applications" zotero  # collect, organize, cite, and share research

# "CHM Reader" of legacy Compiled HTML files.

fancy_echo "Installing Text Editors & IDEs:"
brew cask install --appdir="/Applications" sublime-text3 
brew cask install --appdir="/Applications" atom
    # apm upgrade -c false  # (atom package manager) https://github.com/atom/apm
# brew cask install --appdir="/Applications" mailmate
# bbedit
brew cask install --appdir="/Applications" visual-studio-code
# https://docs.microsoft.com/en-us/visualstudio/mac/installation
# brew cask install --appdir="/Applications" microsoft-office # Office 2016 installer

brew cask install --appdir="/Applications" macvim  # See https://github.com/macvim-dev/macvim 
   # vimtutor
brew cask install --appdir="/Applications" intellij-idea-ce
# brew cask install --appdir="/Applications" libreoffice
#brew cask install --appdir="/Applications" scribus

# One good spell check that works with all the code editors.

brew cask install --appdir="/Applications" sts   # Spring Test Suite for Java
# brew cask install --appdir="/Applications" eclipse-java  # Not STS
   # android-studio from mobile dev ???

#brew cask install --appdir="/Applications" viscosity  # OpenVPN client http://www.sparklabs.com/viscosity/


#fancy_echo "Installing hardware location in case of theft:"
# TODO: Enter API key from the bottom-left corner of the Prey web account Settings page:
#HOMEBREW_NO_ENV_FILTERING=1 API_KEY="abcdef123456" brew cask install --appdir="/Applications" prey
#brew cask install --appdir="/Applications" prey  # to track your mobile devices and laptops


#fancy_echo "Installing Mobile dev:"
#brew install android-sdk
#0. Update the sdk if needed through
#    android update sdk --no-ui
#0. Install NDK (for IL2CPP)
#   https://developer.android.com/ndk/downloads/index.html
#0. Add android-sdk to Unity
#   Unity > Preferences > External Tools > Android, SDK : Browse

#   SHIFT+CMD+G
#   Enter path /usr/local/Cellar/android-sdk/

#fancy_echo "Installing Unity VR dev:"
#1. Create a Unity ID.
#https://github.com/wooga/homebrew-unityversions
#0. Download Unity Editor:
#http://unity3d.com/unity/download/?_ga=2.194647725.1237052200.1507160407-416598928.1507160407
#Alternately, UnityDownloadAssistant-2017.1.1f1.dmg
#2. To install/upgrade Unity3d on a remote mac OS X machine and you only have shell access:
 #  $ alias wget="curl -O -L"
 #  $ wget http://download.unity3d.com/download_unity/unity-3.5.0.dmg
 #  $ hdiutil mount unity-3.5.0.dmg

#3. Script to install:
   # https://bitbucket.org/WeWantToKnow/unity3d_scripts


# see https://wilsonmar.github.io/rdp
# manual download https://rink.hockeyapp.net/apps/5e0c144289a51fca2d3bfa39ce7f2b06/ as of 20 FEB 2018.
    # MD5: B2A14013DE628BDEEBD6CEA395CE5066 


#https://www.eternalstorms.at/yoink/Yoink_-_Simplify_and_Improve_Drag_and_Drop_on_your_Mac/Yoink_-_Simplify_drag_and_drop_on_your_Mac.html


fancy_echo "Installing Docker add-ons:"
if ! command -v docker >/dev/null; then
    fancy_echo "Installing Docker (xhyve):"
    brew cask install --appdir="/Applications" virtualbox
    brew cask install --appdir="/Applications" vagrant
    brew cask install --appdir="/Applications" easyfind
    # brew cask install --appdir="/Applications" kitematic  # runs containers via UI

    # https://pilsniak.com/how-to-install-docker-on-mac-os-using-brew/
    brew install docker docker-compose docker-machine xhyve docker-machine-driver-xhyve
    sudo chown root:wheel $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
    sudo chmod u+s $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
else
    docker -v  # Docker version 18.02.0-ce, build fc4de44
fi

fancy_echo "Installing browsers and browser plug-ins:"
# /Applications/Google Chrome.app
#brew cask install --appdir="/Applications" google-chrome

#brew cask install --appdir="/Applications" firefox
brew cask install --appdir="/Applications" brave  # browser
#brew cask install --appdir="/Applications" opera
#brew cask install --appdir="/Applications" torbrowser

#brew cask install --appdir="/Applications" utorrent
brew cask install --appdir="/Applications" flash-player  # https://github.com/caskroom/homebrew-cask/blob/master/Casks/flash-player.rb
brew cask install --appdir="/Applications" adobe-acrobat-reader
brew cask install --appdir="/Applications" adobe-air
brew cask install --appdir="/Applications" silverlight
# DISCONTINUED: brew cask install --appdir="/Applications" google-notifier

# brew cask install --appdir="/Applications" pocket  # track links for browsers

#brew cask install --appdir="/Applications" flux  # to minimize blue light before sleep. Installed to "~/Applications" by default.

fancy_echo "Installing Collaboration / screen sharing:"
#https://zapier.com/blog/disable-mic-webcam-notifications/
brew cask install --appdir="/Applications" skype  # unselect show birthdays
#brew cask install --appdir="/Applications" skype-for-business  # unselect show birthdays
brew cask install --appdir="/Applications" slack  # installed to "~/Applications" by default.
brew cask install --appdir="/Applications" google-hangouts
brew cask install --appdir="/Applications" zoom   # 32-bit
brew cask install --appdir="/Applications" whatsapp
brew cask install --appdir="/Applications" microsoft-lync
#brew cask install --appdir="/Applications" sococo
brew cask install --appdir="/Applications" keybase  # encrypted https://keybase.io/
# https://www.biba.com/downloads.html
brew cask install --appdir="/Applications" teamviewer
# GONE? brew cask install --appdir="/Applications" Colloquy. ## IRC http://colloquy.info/downloads.html
#brew cask install --appdir="/Applications" hipchat
#brew cask install --appdir="/Applications" joinme
# GONE: brew cask install --appdir="/Applications" gotomeeting   # 32-bit
# blue jeans? (used by ATT)

# Jump Desktop app $30 https://itunes.apple.com/us/app/jump-desktop-remote-desktop/id524141863?mt=12
# brew cask install --appdir="/Applications" real-vnc
    # See http://macappstore.org/real-vnc/ 
    # and https://www.realvnc.com/en/connect/download/viewer/
    # (no uninstaller)

#brew cask install --appdir="/Applications" webex-nbr-player  # 32-bit, had error.
# So Download webexplayer_intel.dmg http://macappstore.org/webex-nbr-player/
# curl https://welcome.webex.com/client/T31L/mac/intel/webexnbrplayer_intel.dmg

#mutemymikefree
#Textual from Appstore


## fancy_echo "Installing Music apps :"
# brew cask install --appdir="/Applications" pandora-one
# brew cask install --appdir="/Applications" amazon-music
# brew cask install --appdir="/Applications" lastfm



## Fonts:
#https://www.fontsquirrel.com/fonts/open-sans
#Copy them into /Library/Fonts (for system wide use) or ~/Library/Fonts (for use by current user).


# download: VMware fusion
#brew install opencv
#brew install tesseract


fancy_echo "Installing media editing:"
# Install $30 Mac app Waltr (from Softorino) to convert media files and transfer them to iPhones/iPads
# See https://www.macworld.com/article/2863171/waltr-converts-and-copies-just-about-any-media-file-to-your-iphone-and-ipad.html

brew cask install --appdir="/Applications" sketch      # SVG editor installed to "~/Applications" by default.
brew cask install --appdir="/Applications" sketch-toolbox

brew install pngcrush
   # See http://osxdaily.com/2013/08/15/pngcrush-mac-os-x/
brew cask install --appdir="/Applications" imageoptim  # shrink image files.

brew cask install --appdir="/Applications" gimp        # classic image editor
#brew cask install --appdir="/Applications" omnigraffle
#brew install graphicsmagick

#fancy_echo "Installing Camtasia for video capture and editing:"
brew cask install --appdir="/Applications" camtasia  #video
brew cask install --appdir="/Applications" audacity  # audio

# brew cask install --appdir="/Applications" creativecloud
# brew cask install --appdir="/Applications" adobe-creative-cloud
# brew cask install --appdir="/Applications" google-earth
# brew install youtube-dl
# brew cask install --appdir="/Applications" vlc   # mp4 video file viewer.

## Gaming
# brew cask install --appdir="/Applications" steam  # http://macappstore.org/steam/
# 

## Devops:
# brew install ansible
# brew install ansible-lint
# brew install kubeadm kubectl kubelet kubernetes-cni
# brew of apt-get install docker.io kubeadm kubectl


# brew cask install --appdir="/Applications" totalfinder

#fancy_echo "Installing Jekyll static website tools:"
#brew install grip.  # https://github.com/joeyespo/grip
# GONE: brew install jekyll


fancy_echo "Installing messaging RabbitMQ:"
brew install rabbitmq
#MONGO_HOST=  Host where MongoDB is running
#MONGO_PORT=  Port where MongoDB is listening for requests

fancy_echo "Installing databases:"
brew install mongodb 
# AMQP_HOST= Host where RabbitMQ is running
# AMQP_PORT= Port where RabbitMQ is listening for requests
brew install redis
brew install exist-db
brew install neo4j
# rstudio
# basex
# httpie
# hyper

# If servers are not in the hosts file, add it:
if ! grep mongodb "/etc/hosts"; then
    # Add -q after grep to display string found.
    fancy_echo "Appending MongoDB to hosts file (password required) ..."
    sudo -- sh -c "echo 127.0.0.1 mongodb >> /etc/hosts"
    # sudo -- spawns a new host to do it.
fi
if ! grep rabbitmq "/etc/hosts"; then
    fancy_echo "Appending rabbitmq to hosts file (password required) ..."
    sudo -- sh -c "echo 127.0.0.1 rabbitmq >> /etc/hosts"
fi
    # sudo -- sh -c -e "echo '192.34.0.03   subdomain.domain.com' >> /etc/hosts";
fancy_echo "Verify resulting contents of /etc/hosts file:"
cat /etc/hosts   # 


#fancy_echo "Installing MySQL database:"
# NO —client-only /// brew install mysql --client-only
#mongoldb
#To have launchd start mongodb now and restart at login:
#  brew services start mongodb
#Or, if you don't want/need a background service you can just run:
#  mongod --config /usr/local/etc/mongod.conf
#==> Summary
#🍺  /usr/local/Cellar/mongodb/3.4.9: 19 files, 284.9MB

#brew cask install --appdir="/Applications" mysql-workbench
#brew cask install --appdir="/Applications" mysqlworkbench

# brew install nginx
brew install tomcat
   #To have launchd start tomcat now and restart at login:
   #brew services start tomcat
   #Or, if you don't want/need a background service you can just run:
   # catalina run

pwd

if [ ! -f "/Applications/Postman.app" ]; then
    fancy_echo "Downloads Postman for REST API dev ..."
#    wget -o Postman-osx-latest.zip https://dl.pstmn.io/download/latest/osx ~/Downloads 
#    unzip -q ~/Downloads/Postman-osx-latest.zip 
#    mv ~/Downloads/Postman.app /Applications/
#    pwd
fi

# Functional Testing:
#sikulix with opencv and selenium
#protractor for recognizing AngularJs
#kafka

# Performance testing:
#brew cask install --appdir="/Applications" JProfiler # https://www.ej-technologies.com/download/jprofiler/files

brew install jmeter --with-plugins  # all plugins
    #open /usr/local/bin/jmeter



fancy_echo "Cloud Foundary CLI:"
brew install cloudfoundry/tap/cf-cli
    # See https://github.com/cloudfoundry/cli#installing-using-a-package-manager

fancy_echo "Google Cloud SDK: (python 2.7)"
brew tap caskroom/cask
brew cask install --appdir="/Applications" google-cloud-sdk
   gcloud -v  # Google Cloud SDK 190.0.
   # gcloud components update

#brew install azure-cli  # https://docs.microsoft.com/cli/azure/overview
#brew cask install --appdir="/Applications" heroku-toolbelt
#pip install awscli



#https://github.com/so-fancy/diff-so-fancy


## Testing:
#brew cask install --appdir="/Applications" adium


## Others

#I do not recommend indescrimately adding software.
#Not only do you waste disk space on tools you never use, you slow down your other work, and can open your #computer up to being hacked:

# https://techsviewer.com/go/gemini-2/  to identify duplicate files.
# Disk Inventory X to analyze disk space usage.

#brew install fish
#brew install calc
#brew install ncdu
#brew install irssi

#brew cask install --appdir="/Applications" screenflow
#brew cask install --appdir="/Applications" flowdock
#brew cask install --appdir="/Applications" fuze
#brew cask install --appdir="/Applications" ghostpath
#brew cask install --appdir="/Applications" omnifocus
#brew cask install --appdir="/Applications" parallels
#brew cask install --appdir="/Applications" SubnetCalc
#brew cask install --appdir="/Applications" disk-inventory-x
#brew cask install --appdir="/Applications" hosts
#brew cask install --appdir="/Applications" vienna

#brew cask install --appdir="/Applications" mailplane
#brew cask install --appdir="/Applications" cyberduck
#brew cask install --appdir="/Applications" dash
#brew cask install --appdir="/Applications" divvy

#brew install watch
#brew install mobile-shell
#brew install unrar

#brew cask install --appdir="/Applications" caffeine
#brew cask install --appdir="/Applications" mamp
#brew cask install --appdir="/Applications" marked
#brew cask install --appdir="/Applications" backblaze
#brew cask install --appdir="/Applications" charles
#brew cask install --appdir="/Applications" flowdock
#brew cask install --appdir="/Applications" ghostpath
#brew cask install --appdir="/Applications" keepassx
#brew cask install --appdir="/Applications" omnifocus
#brew cask install --appdir="/Applications" parallels
#brew cask install --appdir="/Applications" SubnetCalc

#brew cask install --appdir="/Applications" disk-inventory-x

#brew cask install --appdir="/Applications" jumpcut # clipboard
#brew cask install --appdir="/Applications" karabiner # Keyboard customization
#brew cask install --appdir="/Applications" rowanj-gitx # Awesome gitx fork.
#brew cask install --appdir="/Applications" shortcat # kill your mouse

#brew cask install --appdir="/Applications" charles # proxy
#brew cask install --appdir="/Applications" easyfind
#brew cask install --appdir="/Applications" github
#brew cask install --appdir="/Applications" jdownloader


#https://gist.github.com/arctouch-shadowroldan/279d90d2fe414d1bbe02

#http://osxdaily.com/2017/05/30/big-mac-annoyances-fix-them/

#https://gist.github.com/codeinthehole/26b37efa67041e1307db

#https://github.com/fcoury/install

#http://www.vreference.com/2016/05/05/mac-os-x-application-installation-automation/

#https://github.com/ferventcoder/chef-chocolatey-presentation

fancy_echo "To manage Mac apps: see https://github.com/mas-cli/mas"
brew install mas
    #mas signin --dialog mas@example.com
    # mas install 808809998 # Apps must already be in the Purchased tab of the App Store.
    # quip
    # microsoft office
    mas list

# Apps are stored in the "/Applications" folder.

############## Wrap-up:

fancy_echo "Listing of all brews installed (including dependencies automatically added):"
# brew list
ls ~/Library/Caches/Homebrew

fancy_echo "Listing of all brew cask installed (including dependencies automatically added):"
brew info --all

#brew doctor
brew cleanup
brew cask cleanup

fancy_echo “DONE”
