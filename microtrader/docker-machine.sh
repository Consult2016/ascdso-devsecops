#!/bin/sh #for POSIX-complian Bourne shell 

# docker-machine.sh in https://github.com/wilsonmar/docker-machine
# This script is stolen from Justin Menga's course release 10 May 2016 on Pluralsight 
# https://app.pluralsight.com/library/courses/docker-ansible-continuous-delivery/exercise-files
# which shows how to install a "todobackend" app written in Python and Django.
# Based on http://todobackend.com/ to compare the same app created using many other languages.

# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/docker-machine/docker-machine.sh)"

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# Some tools used are now are considered by some as obsolete: docker-machine, vmwarefusion
echo "\n>>> What's installed for commands used in this script?"
   docker -v  # Docker version 18.09.2, build 6247962
   #docker-machine --version  # docker-machine version 0.16.1, build cce350d7
   python --version  # Python 2.7.10
   ansible --version | head -n 1 # 2.8.0
   which docker-machine

echo "\n>>> docker-machine"
 # 0:17 into https://app.pluralsight.com/player?course=docker-ansible-continuous-delivery&author=justin-menga&name=docker-ansible-continuous-delivery-m1&clip=11&mode=live
docker-machine --debug create --driver \
   vmwarefusion --vmwarefusion-cpu-count "4" --vawarefusion-disk-size "60000" --vmwarefusion-memory-size "8192" \
   docker01
   # ERROR: Incorrect Usage.

pip install django==1
# 2:11 into https://app.pluralsight.com/player?course=docker-ansible-continuous-delivery&author=justin-menga&name=docker-ansible-continuous-delivery-m2&clip=2&mode=live
django-admin startproject todobackend
