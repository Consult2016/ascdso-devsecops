#!/bin/bash #for bash v4

# prometheus-setup.sh in https://github.com/wilsonmar/DevSecOps/Prometheus
# This downloads and installs all the utilities related to use of Prometheus
# described at https://wilsonmar.github.io/prometheus
# When an enviornment is opened:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/Prometheus/prometheus-setup.sh)"

# This implements the LinuxAcademy.com course "DevOps Monitoring Deep Dive" by Elle.

######### Starting time stamp, OS versions, command attributes:

######### Bash utility functions:

######### bash completion:
echo -e "$(bash --version | grep 'bash')"
      # GNU bash, version 4.4.19(1)-release (x86_64-apple-darwin17.3.0)

exit

# Create a system user for Prometheus:
 sudo useradd --no-create-home --shell /bin/false prometheus

# Create the directories in which we'll be storing our configuration files and libraries:
 sudo mkdir /etc/prometheus
 sudo mkdir /var/lib/prometheus

# Set the ownership of the /var/lib/prometheus directory:
 sudo chown prometheus:prometheus /var/lib/prometheus

# Pull down the tar.gz file from the Prometheus downloads page:
 cd /tmp/
 wget https://github.com/prometheus/prometheus/releases/download/v2.7.1/prometheus-2.7.1.linux-amd64.tar.gz

# Extract the files:
 tar -xvf prometheus-2.7.1.linux-amd64.tar.gz

# Move the configuration file and set the owner to the prometheus user:
 sudo mv console* /etc/prometheus
 sudo mv prometheus.yml /etc/prometheus
 sudo chown -R prometheus:prometheus /etc/prometheus

# Move the binaries and set the owner:
 sudo mv prometheus /usr/local/bin/
 sudo mv promtool /usr/local/bin/
 sudo chown prometheus:prometheus /usr/local/bin/prometheus
 sudo chown prometheus:prometheus /usr/local/bin/promtool

# Create the service file:
 sudo $EDITOR /etc/systemd/system/prometheus.service

# Concatenate prometheus-setup.txt from github.com/wilsonmar/DevSecOps/Prometheus:
   cat /etc/systemd/system/prometheus.service << https://github.com/wilsonmar/DevSecOps/Prometheus
# Save and exit.

# Reload systemd:
 sudo systemctl daemon-reload

# Start Prometheus, and make sure it automatically starts on boot:
 sudo systemctl start prometheus
 sudo systemctl enable prometheus

# Visit Prometheus in your web browser at PUBLICIP:9090.
   


######### bash.profile configuration:


BASHFILE=$HOME/.bash_profile  # on Macs

# if ~/.bash_profile has not been defined, create it:
if [ ! -f "$BASHFILE" ]; then #  NOT found:
   fancy_echo "Creating blank \"${BASHFILE}\" ..." >>$LOGFILE
   touch "$BASHFILE"
   echo "PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" >>"$BASHFILE"
   # El Capitan no longer allows modifications to /usr/bin, and /usr/local/bin is preferred over /usr/bin, by default.
else
   LINES=$(wc -l < "${BASHFILE}")
   fancy_echo "\"${BASHFILE}\" already created with $LINES lines." >>$LOGFILE
   fancy_echo "Backing up file $BASHFILE to $BASHFILE-$LOG_PREFIX.bak ..."  >>$LOGFILE
   cp "$BASHFILE" "$BASHFILE-$LOG_PREFIX.bak"
fi



######### Disk space consumed:


FREE_DISKBLOCKS_END=$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6) 
DIFF=$(((FREE_DISKBLOCKS_START-FREE_DISKBLOCKS_END)/2048))
echo -e "\n   $DIFF MB of disk space consumed during this script run." >>$LOGFILE
# 380691344 / 182G = 2091710.681318681318681 blocks per GB
# 182*1024=186368 MB
# 380691344 / 186368 G = 2042 blocks per MB

TIME_END=$(date -u +%s);
DIFF=$((TIME_END-TIME_START))
MSG="End of script after $((DIFF/60))m $((DIFF%60))s seconds elapsed."
fancy_echo "$MSG"
echo -e "\n$MSG" >>$LOGFILE
