#!/bin/bash

# python-hello-gcp.sh in https://github.com/wilsonmar/DevSecOps/blob/master/gcp/gcp-python-hello.sh
# This script automates instructions 20 minute Qwik Start -Python on GCP
# at https://www.qwiklabs.com/focuses/1014 which is a part of the Quest
# https://google.qwiklabs.com/quests/37
# The hands-on lab shows you how to create a small App Engine application that displays a short message
# Resources:
# https://www.youtube.com/watch?v=s0-pfuXj1aA&feature=youtu.be
      # Build Apps at Scale with Google App Engine | Google Cloud Labs
# https://cloud.google.com/appengine/docs/about-the-standard-environment#index_of_features
# https://cloud.google.com/products/

# USAGE:
# Instead of typing, copy this command to run in the console within the cloud:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/gcp/gcp-python-hello.sh)"
# by WilsonMar@gmail.com


# MANUAL: 
# MANUAL: Search for "Google App Engine Admin API"
# MANUAL: Click "MANAGE" (even though it says "ENABLE" in the docs)

# MANUAL: Activate cloud shell

git clone https://github.com/GoogleCloudPlatform/python-docs-samples
cd python-docs-samples/appengine/standard/hello_world
pwd

# Use the application using the Google Cloud development server (dev_appserver.py)
# included with the preinstalled App Engine SDK:

# MANUAL: https://console.cloud.google.com/apis/library/appengine.googleapis.com?q=App%20Engine&id=a634ba3f-b36e-4e22-93a1-e80a2e817178&project=qwiklabs-gcp-c7c0bd38b9e58b96&authuser=2

# Cannot Open in background:
dev_appserver.py app.yaml 
   # nohup: ignoring input and appending output to 'nohup.out'
   # MANUAL: Web preview > Preview on port 8080 to see "hello world".
# MANUAL: Press Ctrl+C to exit.

# MANUAL: open a new command line session - pwClick the + next to your Cloud Shell tab to 

# go to the directory that contains the sample code:
cd python-docs-samples/appengine/standard/hello_world

# nano main.py
# Change "Hello, World!" to "Hello, Cruel World!". Exit and save the file.

# Deploy app to App Engine from the root directory of your application where app.yaml file is located:
ls app.yaml
gcloud app deploy

# TODO: MANUAL: Specify number for us-central or whatever region you want.
# Enter Y to continue
   # 	Beginning deployment of service [default]...
   # ╔════════════════════════════════════════════════════════════╗
   # ╠═ Uploading 5 files to Google Cloud Storage                ═╣
   # ╚════════════════════════════════════════════════════════════╝
   # File upload done.
   # Updating service [default]...done.

# To launch your browser enter the following command, then click on the link it provides.
gcloud app browse
   # Did not detect your browser. Go to this link to view your app:
   # https://qwiklabs-gcp-c7c0bd38b9e58b96.appspot.com

# MANUAL: Outside 

exit

# MANUAL: Sign out from Google.
# MANUAL: Click "Check my progress".
# MANUAL: Click "All of them", then "Submit".