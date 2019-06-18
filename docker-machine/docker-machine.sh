#!/bin/sh #for POSIX-complian Bourne shell 

# docker-machine.sh in https://github.com/wilsonmar/docker-machine
# This downloads and installs all the utilities related to use of Git,
# customized based on specification in file secrets.sh within the same repo.
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/docker-machine/docker-machine.sh)"

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# This script is based on Justin Menga's course release 10 May 2016 on Pluralsight 
# https://app.pluralsight.com/library/courses/docker-ansible-continuous-delivery/exercise-files

# Tools used: docker-machine, vmwarefusion

# 0:17 into https://app.pluralsight.com/player?course=docker-ansible-continuous-delivery&author=justin-menga&name=docker-ansible-continuous-delivery-m1&clip=11&mode=live

docker-machine create --driver vmwarefusion --vmwarefusion-cpu-count "4" \
   --vawarefusion-disk-size "60000" --vmwarefusion-memory-size "8192" docker01

