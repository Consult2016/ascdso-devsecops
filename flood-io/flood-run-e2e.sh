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
FLOOD_PROJECT="Default"  # "the-internet-dev01"
TYPESCRIPT_URL="https://raw.githubusercontent.com/flood-io/element/master/examples/internet-herokuapp/14-Dynamic_Loading.ts"
FLOOD_REGION="ap-southeast-2"
FLOOD_INST_TYPE="m4.xlarge"
meta=""  # QUESTION: What goes in this?

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
source ~/.flood-secrets.env  # QUESTON: Where is this when invoked within Jenkins?
# PROTIP: use environment variables to pass links to where the secret is really stored: use an additional layer of indirection.
# From https://app.flood.io/account/user/security
if [ -z "${FLOOD_API_TOKEN}" ]; then
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
echo -e "\n>>> [$(date +%FT%T)+00:00] Starting flood for uuid response:"
curl "$TYPESCRIPT_URL" -H 'Connection: keep-alive' \
-H 'Pragma: no-cache' -H 'Cache-Control: no-cache' \
-H 'Upgrade-Insecure-Requests: 1' \
-H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36' \
-H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-User: ?1' \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3' \
-H 'Sec-Fetch-Site: none' \
-H 'Accept-Encoding: gzip, deflate, br' \
-H 'Accept-Language: en-US,en;q=0.9,es;q=0.8' \
--compressed >$SCRIPT_FULL_PATH

if [ ! -f "$SCRIPT_FULL_PATH" ]; then
   echo -e "\n>>> SCRIPT_FULL_PATH not available. Exiting..."
   exit 9
else
   echo -e "\n>>> SCRIPT_FULL_PATH = $SCRIPT_FULL_PATH..."
fi

echo -e "\n>>> [$(date +%FT%T)+00:00] run flood_uuid"
flood_uuid=$(curl -u "$FLOOD_USER" -X POST https://api.flood.io/grids \
 -H "Accept: application/vnd.flood.v2+json" \
 -F "flood[tool]=flood-chrome" \
 -F "flood[project]=$FLOOD_PROJECT" \
 -F "flood[threads]=1" \
 -F "flood[privacy]=public" \
 -F "flood[name]=ElementTest" \
 -F "flood[tag_list]=shakout" \
 -F "flood[meta]=$meta" \
 -F "flood_files[]=@$SCRIPT_FULL_PATH" \
 -F "flood[grids][][infrastructure]=demand" \
 -F "flood[grids][][instance_quantity]=1" \
 -F "flood[grids][][region]=$FLOOD_REGION" \
 -F "flood[grids][][instance_type]=$FLOOD_INST_TYPE" \
 -F "flood[grids][][stop_after]=60" | jq -r ".uuid" )

# https://api.flood.io/floods

echo -e "\n>>> [$(date +%FT%T)+00:00] Waiting for flood $flood_uuid"
while [ $(curl --silent --user $FLOOD_API_TOKEN: https://api.flood.io/floods/$flood_uuid | \
  jq -r '.status == "finished"') = "false" ]; do
  echo -n "."
  sleep 3
done

echo -e "\n>>> [$(date +%FT%T)+00:00] Get the summary report"
flood_report=$(curl --silent --user $FLOOD_API_TOKEN: https://api.flood.io/floods/$flood_uuid/report | \
  jq -r ".summary")

echo
echo -e "\n>>> [$(date +%FT%T)+00:00] Detailed results at https://flood.io/$flood_uuid"
echo "$flood_report"

# Optionally store the CSV results
echo
echo -e "\n>>> [$(date +%FT%T)+00:00] Storing CSV results at results.csv"
curl --silent --user $FLOOD_API_TOKEN: https://api.flood.io/floods/$flood_uuid/result.csv > result.csv

