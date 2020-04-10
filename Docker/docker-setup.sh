#!/bin/bash
# This is hello-world.sh from https://github.com/wilsonmar/DevSecOps/
# by WilsonMar@gmail.com
# Described in https://

# This script is used to verify that scripts can run
# Copy this command (without the #) and paste in your terminal:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/hello-world.sh)"

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