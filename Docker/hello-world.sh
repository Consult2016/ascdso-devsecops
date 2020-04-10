#!/bin/bash
# This is docker-setup.sh from 
# https://github.com/wilsonmar/DevSecOps/master/Docker/docker-setup.sh
# by WilsonMar@gmail.com
# Described in https://wilsonmar.github.io/docker-setup
# based on     https://wilsonmar.github.io/bash-coding

# This script is used to verify that scripts can run
# Copy this command (without the #) and paste in your terminal:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/docker-setup.sh)"

echo "Hello world! v1.4"

### OS detection:
platform='unknown'
unamestr=$( uname )
if [ "$unamestr" == 'Darwin' ]; then
           platform='macos'
elif [ "$unamestr" == 'Linux' ]; then
             platform='linux'
elif [ "$unamestr" == 'FreeBSD' ]; then
             platform='freebsd'
elif [ "$unamestr" == 'Windows' ]; then
             platform='windows'
fi
echo "I'm $unamestr = $platform"


  if [ $platform == 'macos' ]; then
   alias ls='ls --color=auto'
elif [ $platform == 'linux' ]; then
   alias ls='ls --color=auto'
elif [ $platform == 'freebsd' ]; then
   alias ls='ls -G'
elif [ $platform == 'windows' ]; then
   alias ls='dir'
fi

echo "End of script."