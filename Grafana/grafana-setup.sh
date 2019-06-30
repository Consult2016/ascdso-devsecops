#!/bin/bash #for bash v4

# grafana-setup.sh in https://github.com/wilsonmar/DevSecOps/Grafana
# This downloads and installs all the utilities related to use of Grafana
# described at https://wilsonmar.github.io/grafana
# When an enviornment is opened, copy and paste this on the Terminal:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/Grafana/grafana-setup.sh)"

# This implements the LinuxAcademy.com course "DevOps Monitoring Deep Dive" by Elle 
# at https://linuxacademy.com/cp/courses/lesson/course/4049/lesson/4/module/329

######### Starting time stamp, OS versions, command attributes:

######### Bash utility functions:

######### bash completion:
echo -e "$(bash --version | grep 'bash')"
      # GNU bash, version 4.4.19(1)-release (x86_64-pc-linux-gnu)
      # GNU bash, version 4.4.19(1)-release (x86_64-apple-darwin17.3.0)

######### Tutorial actions:

# Install the prerequisite package:
   sudo apt-get install libfontconfig

# Download and install Grafana using the .deb package provided on the Grafana download page:
   wget https://dl.grafana.com/oss/release/grafana_5.4.3_amd64.deb
   sudo dpkg -i grafana_5.4.3_amd64.deb

# Ensure Grafana starts at boot:
   sudo systemctl enable --now grafana-server

#  Access Grafana's web UI by going to IPADDRESS:3000.
   RESPONSE=$( curl http://54.193.104.253:3000 )
   # TODO: 

# Log in with the username admin and the password admin. Reset the password when prompted.
# Add a Data Source


echo "END OF SCRIPT"