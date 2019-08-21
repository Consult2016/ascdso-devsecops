#!/bin/bash

# flood-run-e2e.sh in https://github.com/wilsonmar/DevSecOps/tree/master/flood-io
# from https://docs.flood.io/#end-to-end-example retrieved 8 July 2019.
# to launch and run flood tests.
# Written by WilsonMar@gmail.com

# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/flood-io/flood-run-e2e.sh)"

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

set -e  # exit script if any command returnes a non-zero exit code.
# set -x  # display every command.

# Default run parameters:
FLOOD_PROJECT="default"  # "the-internet-dev01"
TYPESCRIPT_URL="https://raw.githubusercontent.com/flood-io/element/master/examples/internet-herokuapp/14-Dynamic_Loading.ts"
FLOOD_REGION="us-east-1"
FLOOD_INST_TYPE="m5.xlarge"

# Verify availability of Typescript file:
if wget --spider "$TYPESCRIPT_URL" 2>/dev/null; then
   echo -e "\n>>> $TYPESCRIPT_URL available."
fi

## Reset data from previous run:
unset $FLOOD_API_TOKEN
unset $FLOOD_USER
SCRIPT_FULL_PATH="$PWD/test.ts"
if [ -f "$SCRIPT_FULL_PATH" ]; then
   echo -e "\n>>> SCRIPT_FULL_PATH not available from previous run. Continuing..."
else
   echo -e "\n>>> SCRIPT_FULL_PATH = $SCRIPT_FULL_PATH..."
fi
# rm "$SCRIPT_FULL_PATH"

## Obtain secrets from flood-run-e2e.var or other mechanism
#source ~/.flood-secrets.env  # QUESTON: Where is this when invoked within Jenkins?
# PROTIP: use environment variables to pass links to where the secret is really stored: use an additional layer of indirection.
# From https://app.flood.io/account/user/security
FLOOD_API_TOKEN="flood_live_2da17a993632dbdfd4d1c905f26f249c17c869b0bd"
FLOOD_USER=$FLOOD_API_TOKEN+":x"
if [ -z "$FLOOD_API_TOKEN" ]; then
   echo -e "\n>>> FLOOD_API_TOKEN not available. Exiting..."
   exit 9
else
   echo -e "\n>>> FLOOD_API_TOKEN available. Continuing..."
fi
# To sign into https://app.flood.io/account/user/security (API Access)
if [ -z "$FLOOD_USER" ]; then
   echo -e "\n>>> FLOOD_USER not available. Exiting..."
   exit 9
else
   echo -e "\n>>> FLOOD_USER available. Continuing..."
fi


# TODO: Use GitHub API to lookup and store in a file.
   # See https://developer.github.com/v3/guides/basics-of-authentication/
   # Run script for each row.

   if ! command -v brew >/dev/null; then
      echo -e "\n>>> Installing Homebrew, a pre-requisite for installing stuff on MacOS..."
      ruby -e "$( curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install )"
      brew tap caskroom/cask
   fi
   echo -e "\n>>> $( brew --version ) is installed."

   # Make sure jq is installed to make parsing JSON responses:
   if ! command -v jq >/dev/null; then
      echo -e "\n>>> Installing jq, a pre-requisite for parsing JSON within Batch scripts..."
      brew install jq  # http://stedolan.github.io/jq/download/
   fi
   echo -e "\n>>> $( jq --version ) installed."  # jq-1.6

   if ! command -v wget >/dev/null; then
      echo -e "\n>>> Installing wget, a pre-requisite for this Batch script..."
      brew install wget
   fi
   echo -e "\n>>> $( wget --version | grep "Wget " ) installed."  # 1.20.3


# TODO: Create project "the-internet-dev01" on Flood GUI

echo -e "\n>>> At $PWD"

# Start a flood - see https://docs.flood.io/floods/post-floods
echo -e "\n>>> [$(date +%FT%T)+00:00] create $TYPESCRIPT_URL"
curl $TYPESCRIPT_URL > $SCRIPT_FULL_PATH

if [ ! -f "$SCRIPT_FULL_PATH" ]; then
   echo -e "\n>>> SCRIPT_FULL_PATH not available. Exiting..."
   exit 9
else
   echo -e "\n>>> SCRIPT_FULL_PATH = $SCRIPT_FULL_PATH..."
fi

echo -e "\n>>> [$(date +%FT%T)+00:00] run flood_uuid"
flood_uuid=$( curl -u $FLOOD_API_TOKEN: \
-X POST https://api.flood.io/floods \
-F "flood[tool]=flood-chrome" \
-F "flood[threads]=1" \
-F "flood[rampup]=1" \
-F "flood[duration]=360" \
-F "flood[privacy]=public" \
-F "flood[project]=$FLOOD_PROJECT" \
-F "flood[name]=Element_Test" \
-F "flood_files[]=@$SCRIPT_FULL_PATH" \
-F "flood[grids][][infrastructure]=demand" \
-F "flood[grids][][instance_quantity]=1" \
-F "flood[grids][][region]=$FLOOD_REGION" \
-F "flood[grids][][instance_type]=$FLOOD_INST_TYPE" \
-F "flood[grids][][stop_after]=12" | jq -r ".uuid" )

# https://api.flood.io/floods

echo -e "\n>>> [$(date +%FT%T)+00:00] Waiting for flood $flood_uuid"
while [ $(curl --silent --user $FLOOD_API_TOKEN: https://api.flood.io/floods/$flood_uuid | \
  jq -r '.status == "finished"') = "false" ]; do
  echo -n "."
  sleep 10
done

echo -e "\n>>> [$(date +%FT%T)+00:00] Get the summary report"
flood_report=$(curl --silent --user $FLOOD_API_TOKEN: https://api.flood.io/floods/$flood_uuid/report | \
  jq -r ".summary")

echo -e "\n>>> [$(date +%FT%T)+00:00] Detailed results at https://flood.io/$flood_uuid"
echo "$flood_report"

# Optionally store the CSV results
echo -e "\n>>> [$(date +%FT%T)+00:00] Storing CSV results at results.csv"
curl --silent --user $FLOOD_API_TOKEN: https://api.flood.io/floods/$flood_uuid/result.csv > result.csv

if [ ! -f result.csv ]; then
   echo -e "\n>>> result.csv not available. Exiting..."
   exit 9
else
   echo -e "\n>>> result.csv ..."
   head 1 result.csv
      # {"error":"Sorry, we cannot find that resource. If you'd like assistance please contact support@flood.io"}
fi
