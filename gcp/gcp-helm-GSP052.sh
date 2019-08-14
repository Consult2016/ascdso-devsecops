#!/bin/bash -e

# SCRIPT STATUS: UNDER CONSTRUCTION.
# This performs the commands described in the "Helm Package Manager" (GSP052) hands-on lab at
#    https://www.qwiklabs.com/focuses/1044

# Instead of typing, copy this command to run in the console within the cloud:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/gcp/gcp-helm-GSP052.sh)"

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

# ---------------------------------- exit

echo ">>> create my-cluster:"
gcloud container clusters create my-cluster \
--scopes "https://www.googleapis.com/auth/projecthosting,storage-rw"
   # Created [https://container.googleapis.com/v1/projects/qwiklabs-gcp-0286d80b4438f082/zones/us-central1-a/clusters/my-cluster].
   # kubeconfig entry generated for my-cluster.
   # NAME        ZONE           MASTER_VERSION  MASTER_IP       MACHINE_TYPE   NODE_VERSION  NUM_NODES  STATUS
   # my-cluster  us-central1-f  1.9.7-gke.3           35.188.161.231  n1-standard-1  1.9.7         3          RUNNING


exit







echo ">>> Congratulations."
