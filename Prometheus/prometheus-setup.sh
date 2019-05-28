#!/bin/bash #for bash v4

# prometheus-setup.sh in https://github.com/wilsonmar/DevSecOps/Prometheus
# This downloads and installs all the utilities related to use of Prometheus
# described at https://wilsonmar.github.io/prometheus
# When an enviornment is opened, copy and paste this on the Terminal:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/Prometheus/prometheus-setup.sh)"

# This implements the LinuxAcademy.com course "DevOps Monitoring Deep Dive" by Elle 
# at https://linuxacademy.com/cp/courses/lesson/course/4049/lesson/2/module/329

######### Starting time stamp, OS versions, command attributes:

######### Bash utility functions:

######### bash completion:
echo -e "$(bash --version | grep 'bash')"
      # GNU bash, version 4.4.19(1)-release (x86_64-pc-linux-gnu)
      # GNU bash, version 4.4.19(1)-release (x86_64-apple-darwin17.3.0)

######### Tutorial actions:

# Create a system user named "prometheus":
   sudo useradd --no-create-home --shell /bin/false prometheus
   # Provide password for cloud_user here.

# Create the directories to store configuration files and libraries:
   sudo mkdir /etc/prometheus
   sudo mkdir /var/lib/prometheus

# Set the ownership of the /var/lib/prometheus directory:
   sudo chown prometheus:prometheus /var/lib/prometheus

# Pull down the tar.gz file from the Prometheus downloads page:
   cd /tmp/
   wget https://github.com/prometheus/prometheus/releases/download/v2.7.1/prometheus-2.7.1.linux-amd64.tar.gz
      # Saving to: ‘prometheus-2.7.1.linux-amd64.tar.gz.1’
      # prometheus-2.7.1.linux-amd64. 100%[==============================================>]  36.57M  17.8MB/s    in 2.1s    
      # 2019-05-28 05:06:05 (17.8 MB/s) - ‘prometheus-2.7.1.linux-amd64.tar.gz.1’ saved [38342763/38342763]
   ls -al
      # LICENSE NOTICE console_libraries consles prometheus prometheus.yml promtool

# Extract the files:
   tar -xvf prometheus-2.7.1.linux-amd64.tar.gz
# ADDED:    
   cd /tmp/prometheus-2.7.1.linux-amd64/

# Move the configuration file and set the owner to the prometheus user:
   sudo mv console* /etc/prometheus
   sudo mv prometheus.yml /etc/prometheus
   sudo chown -R prometheus:prometheus /etc/prometheus

# Move the binaries and set the owner:
   sudo mv prometheus /usr/local/bin/
   sudo mv promtool /usr/local/bin/
   sudo chown prometheus:prometheus /usr/local/bin/prometheus
   sudo chown prometheus:prometheus /usr/local/bin/promtool

# INSTEAD OF: sudo $EDITOR /etc/systemd/system/prometheus.service
# Concatenate prometheus-setup.txt from github.com/wilsonmar/DevSecOps/Prometheus:
   curl -O https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/Prometheus/prometheus-setup.service.txt
   sudo mv prometheus-setup.service.txt prometheus.service
   sudo mv prometheus.service /etc/systemd/system/prometheus.service
   ls /etc/systemd/system/prometheus.service -al
      # -rw-rw-r-- 1 cloud_user cloud_user 447 May 28 05:18 /etc/systemd/system/prometheus.service

# Reload systemd:
   sudo systemctl daemon-reload

# Start Prometheus, and make sure it automatically starts on boot:
   sudo systemctl start prometheus
   sudo systemctl enable prometheus
      # Created symlink /etc/systemd/system/multi-user.target.wants/prometheus.service → /etc/systemd/system/prometheus.service.

# Visit Prometheus in your web browser at PUBLICIP:9090.  ADD: 
   RESPONSE=$( curl http://localhost:9090 )
      # <a href="/graph">Found</a>.

## ADDED: Verify the response $RESPONSE.

# Confirm the creation of the existing Docker image:
   docker image list
      # The response lists "forethought" as a Docker image.
      # REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
      # forethought         latest              532cf27aa4eb        3 months ago        74MB
      # node                10-alpine           fe6ff768f798        3 months ago        70.7MB



# Create the alertmanager system user:
  sudo useradd --no-create-home --shell /bin/false alertmanager

# Create the /etc/alertmanager directory:
  sudo mkdir /etc/alertmanager

# Download Alertmanager from the Prometheus downloads page:
  cd /tmp/
  wget https://github.com/prometheus/alertmanager/releases/download/v0.16.1/alertmanager-0.16.1.linux-amd64.tar.gz
     # Saving to: ‘alertmanager-0.16.1.linux-amd64.tar.gz’
     # alertmanager-0.16.1.linux-amd 100%[==============================================>]  18.19M  16.9MB/s    in 1.1s    
     # 2019-05-28 05:51:19 (16.9 MB/s) - ‘alertmanager-0.16.1.linux-amd64.tar.gz’ saved [19070056/19070056]

# Extract the files:
  tar -xvf alertmanager-0.16.1.linux-amd64.tar.gz
# ADDED:    
  cd /tmp/alertmanager-0.16.1.linux-amd64/
  ls -al
     # LICENSE  NOTICE  alertmanager  alertmanager.yml  amtool

# Move the binaries:
 sudo mv alertmanager /usr/local/bin/
 sudo mv amtool /usr/local/bin/

# Set the ownership of the binaries:
 sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager
 sudo chown alertmanager:alertmanager /usr/local/bin/amtool

# Move the configuration file into the /etc/alertmanager directory:
 sudo mv alertmanager.yml /etc/alertmanager/

# Set the ownership of the /etc/alertmanager directory:
 sudo chown -R alertmanager:alertmanager /etc/alertmanager/

# Create the alertmanager.service file for systemd:
# INSTEAD OF: sudo $EDITOR /etc/systemd/system/alertmanager.service
 wget https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/Prometheus/alertmanager.service.txt

# Save and exit.
# Stop Prometheus, and then update the Prometheus configuration file to use Alertmanager:
 sudo systemctl stop prometheus
 wget https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/Prometheus/prometheus-alertering.yml
 prometheus-alertering
 # INSTEAD OF sudo $EDITOR /etc/prometheus/prometheus.yml

# Reload systemd, and then start the prometheus and alertmanager services:
   sudo systemctl daemon-reload
   sudo systemctl start prometheus
   sudo systemctl start alertmanager

# Make sure alertmanager starts on boot:
   sudo systemctl enable alertmanager

# Visit PUBLICIP:9093 in your browser to confirm Alertmanager is working.
   RESPONSE=$( curl http://localhost:9093 )
      # <a href="/graph">Found</a>.

## ADDED: Verify the response $RESPONSE.


echo "END OF SCRIPT"