#!/bin/bash -e

# SCRIPT STATUS: UNDER CONSTRUCTION.
# This performs the commands described in the "Helm Package Manager" (GSP052) hands-on lab at
#    https://www.qwiklabs.com/focuses/1044

# Instead of typing, copy this command to run in the console within the cloud:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/gcp/gcp-helm-GSP052.sh)"

# The script, by Wilson Mar and others,
# adds steps to grep values into variables for variation and verification,
# so you can spend time learning and experimenting rather than typing and fixing typos.
# This script deletes folders left over from previous run so can be rerun (within the same session).

uname -a
   # RESPONSE: Linux cs-6000-devshell-vm-91a4d64c-2f9d-4102-8c22-ffbc6448e449 3.16.0-6-amd64 #1 SMP Debian 3.16.56-1+deb8u1 (2018-05-08) x86_64 GNU/Linux

#gcloud auth list
   #           Credentialed Accounts
   # ACTIVE  ACCOUNT
   #*       google462324_student@qwiklabs.net
   #To set the active account, run:
   #    $ gcloud config set account `ACCOUNT`

GCP_PROJECT=$(gcloud config list project | grep project | awk -F= '{print $2}' )
   # awk -F= '{print $2}'  extracts 2nd word in response:
   # project = qwiklabs-gcp-9cf8961c6b431994
   # Your active configuration is: [cloudshell-19147]
PROJECT_ID=$(gcloud config list project --format "value(core.project)")
echo ">>> GCP_PROJECT=$GCP_PROJECT, PROJECT_ID=$PROJECT_ID"  # response: "qwiklabs-gcp-9cf8961c6b431994"

RESPONSE=$(gcloud compute project-info describe --project $GCP_PROJECT)
   # Extract from:
   #items:
   #- key: google-compute-default-zone
   # value: us-central1-a
   #- key: google-compute-default-region
   # value: us-central1
   #- key: ssh-keys
#echo ">>> RESPONSE=$RESPONSE"
#TODO: Extract value: based on previous line key: "google-compute-default-region"
#  cat "$RESPONSE" | sed -n -e '/Extract from:/,/<\/footer>/ p' | grep -A2 "key: google-compute-default-region" | sed 's/<\/\?[^>]\+>//g' | awk -F' ' '{ print $4 }'; rm -f $outputFile
export REGION="us-central1"
echo ">>> REGION=$REGION"

GCP_ZONE="us-central1-c"
echo ">>> GCP_ZONE=$GCP_ZONE"

exit


# Create a new instance:
gcloud compute instances create gcelab --zone $GCP_ZONE
   # NAME       ZONE           MACHINE_TYPE  PREEMPTIBLE INTERNAL_IP EXTERNAL_IP    STATUS
   # gcelab us-central1-c n1-standard-1             10.240.X.X  X.X.X.X        RUNNING

# Create a new persistent disk:
gcloud compute disks create mydisk --size=200GB --zone $GCP_ZONE
   # NAME   ZONE          SIZE_GB TYPE        STATUS
   # mydisk us-central1-c 200     pd-standard READY

# Attach a persistent disk to the virtual machine instance gcelab:
gcloud compute instances attach-disk gcelab \
   --device-name mydevice1 \
   --disk mydisk --zone $GCP_ZONE
   # Updated [https://www.googleapis.com/compute/v1/projects/qwiklabs-gcp-d12e3215bb368ac5/zones/us-central1-c/instances/gcelab].
   # NOTE: If device-name is not specified, default is like "scsi-0Google_PersistentDisk_persistent-disk-1
   
# SSH in the virtual machine:
echo Y | gcloud compute ssh gcelab --zone $GCP_ZONE
   # WARNING: The public SSH key file for gcloud does not exist.
   # WARNING: The private SSH key file for gcloud does not exist.
   # WARNING: You do not have an SSH key for gcloud.
   # WARNING: SSH keygen will be executed to generate a key.
   # This tool needs to create the directory
   # [/home/gcpstaging8246_student/.ssh] before being able to generate SSH keys.
   # Do you want to continue (Y/n)?  y

# Find the disk device:
ls -l /dev/disk/by-id/
   # lrwxrwxrwx 1 root root  9 Feb 27 02:25 google-persistent-disk-1 -> ../../sdb

# To Formatting and mounting the persistent disk:
   # First, Make a mount point:
   sudo mkdir /mnt/mydisk

   # Next, format the disk with a single ext4 filesystem using the mkfs tool. This command deletes all data from the specified disk:
   sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1
      # Last lines of the output:
      # Allocating group tables: done     
      # Writing inode tables: done     
      # Creating journal (262144 blocks): done
      # Writing superblocks and filesystem accounting information: done

   # Mount the disk to the instance with the discard option enabled:
   sudo mount -o discard,defaults /dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1 /mnt/mydisk

# Automatically mount the disk on restart by editing file /etc/fstab 
# TODO: Add the following below the line that starts with "UUID=..."
sed -i "/dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1 /mnt/mydisk ext4 defaults 1 1"
   # in file /etc/fstab

# Alternately, It's usually better to use the UUID in the /etc/fstab rather than /dev/anything .. 
# and you can just append it in the /etc/fstab rather than using a sed.

# For fast local SSDs on Linux images that supports NVMe,
# see https://cloud.google.com/compute/docs/disks/local-ssd#create_a_local_ssd

# Congratulations.
