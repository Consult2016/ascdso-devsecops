#!/bin/bash

# jenkins-on-mac.sh
# See https://www.packtpub.com/mapt/video/virtualization_and_cloud/9781788478649/62204/63429/install-jenkins-with-docker

docker pull jenkins/jenkins:lts

docker run --rm -it -p 8888:8888 -v "`pwd`/../src:/src" -v "`pwd`/../data:/data" \
   -w /src supervisely_anpr  bash
I'
# https://rawgit.com/sudo-bmitch/dc2018/master/faq-stackoverflow-lightning.html#29
docker run -p 8080:8080 -p 50000:50000 -v jenkins home:/var/jenkins jenkins/jenkis:lts
   # See https://rawgit.com/sudo-bmitch/dc2018/master/faq-stackoverflow-lightning.html#1
      # by Brandon Mitchell (@sudo_bmitch)

# Alternative: https://github.com/mixja/jenkins
# Jenkins Docker image with Docker, Ansible and Boto3 installed

