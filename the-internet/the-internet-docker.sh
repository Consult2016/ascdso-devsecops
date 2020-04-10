#!/usr/bin/env bash

# This is the-internet-docker.sh in https://github.com/wilsonmar/DevSecOps/the-internet
# When an Ubuntu terminal is opened, copy and paste this on the Terminal:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/the-internet/the-internet-docker..sh)"
# to install and configure all the utilities related to use of the-internet
# described at https://wilsonmar.github.io/flood-the-internet

sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce
# verify:
sudo systemctl status docker
sudo docker --version
# 
sudo docker pull gprestes/the-internet
sudo docker run -d -p 7080:5000 gprestes/the-internet
# TODO: Identify the Docker ID to a variable:
sudo docker ps -aqf "name=containername"

# https://stackoverflow.com/questions/34496882/get-docker-container-id-from-container-name
CONTAINER_ID=$( ps -fed | grep docker )  # not working here.
echo "CONTAINER_ID=$CONTAINER_ID"

# if CONTAINER_ID not blank, write variable variable in a shell file so calling the script retrieves CONTAINER_ID :
cat >the-internet-docker-CONTAINER_ID.sh <<EOF
#!/bin/bash 
printf "CONTAINER_ID=$CONTAINER_ID" 
EOF
