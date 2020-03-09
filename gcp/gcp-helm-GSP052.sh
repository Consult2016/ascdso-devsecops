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
set -e  # stop on error.

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
gcloud config set compute/zone "$GCP_ZONE"

# ---------------------------------- exit

echo ">>> create my-cluster:"
gcloud container clusters create my-cluster \
   --scopes "https://www.googleapis.com/auth/projecthosting,storage-rw"
   # Created [https://container.googleapis.com/v1/projects/qwiklabs-gcp-0286d80b4438f082/zones/us-central1-a/clusters/my-cluster].
   # kubeconfig entry generated for my-cluster.
   # NAME        ZONE           MASTER_VERSION  MASTER_IP       MACHINE_TYPE   NODE_VERSION  NUM_NODES  STATUS
   # my-cluster  us-central1-f  1.9.7-gke.3           35.188.161.231  n1-standard-1  1.9.7         3          RUNNING

# Install Kubernetes?

# Check for progress here.

echo ">>> kubectl config current-context"
kubectl config current-context
   # gke_qwiklabs-gcp-0286d80b4438f082_us-central1-f_my-cluster

echo ">>> kubectl cluster-info:"
kubectl cluster-info
   # Kubernetes master is running at https://35.193.168.237
   # GLBCDefaultBackend is running at https://35.193.168.237/api/v1/namespaces/kube-system/services/default-http-backend:http/proxy
   # Heapster is running at https://35.193.168.237/api/v1/namespaces/kube-system/services/heapster/proxy
   # KubeDNS is running at https://35.193.168.237/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
   # Metrics-server is running at https://35.193.168.237/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy

echo ">>> Install Helm"
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
   #   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
   #                                  Dload  Upload   Total   Spent    Left  Speed
   # 100  7001  100  7001    0     0  19175      0 --:--:-- --:--:-- --:--:-- 19180
chmod 700 get_helm.sh


echo ">>> make a tiller service account:"
kubectl -n kube-system create sa tiller
   # serviceaccount/tiller created

echo ">>> bind clusterrole (a set of rules around the cluster) to the service account:"
kubectl create clusterrolebinding tiller --clusterrole cluster-admin \
   --serviceaccount=kube-system:tiller
   # clusterrolebinding.rbac.authorization.k8s.io/tiller created

helm init --service-account tiller
helm init --service-account tiller


make sure that the Tiller server is running correctly. Run the following command:
kubectl get po --namespace kube-system
   # NAME                                                   READY   STATUS    RESTARTS   AGE
   # tiller-deploy-7b659b7fbd-tbt9l                         1/1     Running   0          29s

echo ">>> helm version"
helm version
   # Client: &version.Version{SemVer:"v2.14.1", GitCommit:"5270352a09c7e8b6e8c9593002a73535276507c0", GitTreeState:"clean"}
   # Server: &version.Version{SemVer:"v2.14.1", GitCommit:"5270352a09c7e8b6e8c9593002a73535276507c0", GitTreeState:"clean"}

echo ">>> helm repo update"
helm repo update
   # ...Successfully got an update from the "stable" chart repository
   # Update Complete.


echo ">>> Get HELM_NAME from helm install ..."
HELM_NAME=$(helm install stable/mysql | tee | grep "NAME:")
helm install stable/mysql

   ### Check here.

echo ">>> Get HELM_SECRET..."
HELM_SECRET=$( kubectl get secret --namespace default "$HELM_NAME" \
   -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo )


echo ">>> Install an Ubuntu Pod to use as a client"
kubectl run -i --tty ubuntu --image=ubuntu:16.04 --restart=Never -- bash -il


echo ">>> Install the MySQL client"
apt-get update && apt-get install mysql-client -y
   # etting up mysql-client (5.7.27-0ubuntu0.16.04.1) ...
   # Processing triggers for libc-bin (2.23-0ubuntu11) ...

echo ">>> Connect to MYSQL Database with a secret:"
# mysql -h nihilist-hummingbird-sql -p
mysql -h "$HELM_NAME" -p  <<EOF
$HELM_SECRET
EOF

# The cluster role "cluster-admin" is bound to the tiller service account.


echo ">>> Congratulations."
