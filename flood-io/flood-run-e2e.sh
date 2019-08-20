#!/bin/bash

# flood-run-e2e.sh in https://github.com/wilsonmar/DevSecOps/tree/master/flood-io
# from https://docs.flood.io/#end-to-end-example retrieved 8 July 2019.
# to launch and run flood tests.
# Written by WilsonMar@gmail.com

# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/DevSecOps/master/flood-io/flood-run-e2e.sh)"

# This is free software; see the source for copying conditions. There is NO
# warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

set -e  # exit script if any command returnes a non-zero exit code.

# Default run parameters:
TYPESCRIPT_URL="https://raw.githubusercontent.com/flood-io/element/master/examples/internet-herokuapp/14-Dynamic_Loading.ts"
FLOOD_REGION="ap-southeast-2"
FLOOD_INST_TYPE="m4.xlarge"
meta=""  # QUESTION: What goes in this?

# Verify availability of Typescript file:
if wget --spider "$TYPESCRIPT_URL" 2>/dev/null; then
   echo ">>> $TYPESCRIPT_URL available."
fi

## Obtain secrets from flood-run-e2e.var or other mechanism
unset $FLOOD_USER
unset $FLOOD_API_TOKEN
source ~/.flood-secrets.env  # QUESTON: Where is this when invoked within Jenkins?
# From https://app.flood.io/account/user/security
if [ -z "${FLOOD_API_TOKEN}" ]; then
   echo ">>> FLOOD_API_TOKEN not available. Exiting..."
   exit 9
else
   echo ">>> FLOOD_API_TOKEN available. Continuing..."
fi
# To sign into https://app.flood.io/account/user/security (API Access)
if [ -z "$FLOOD_USER" ]; then
   echo ">>> FLOOD_USER not available. Exiting..."
   exit 9
else
   echo ">>> FLOOD_USER available. Continuing..."
fi
# PROTIP: use environment variables to pass links to where the secret is really stored: use an additional layer of indirection.


# TODO: Use GitHub API to lookup and store in a file.
   # See https://developer.github.com/v3/guides/basics-of-authentication/
   # Run script for each row.

# Make sure jq is installed to make parsing JSON responses:
   if ! command -v jq >/dev/null; then
      echo ">>> Installing jq, a pre-requisite for parsing JSON within Batch scripts..."
      brew install jq  # http://stedolan.github.io/jq/download/
   fi
      echo ">>> $(jq --version) installed."  # jq-1.6


# Start a flood - see https://docs.flood.io/floods/post-floods
echo ">>> [$(date +%FT%T)+00:00] Starting flood for uuid response:"
flood_uuid=$(curl -u "$FLOOD_USER:" -X POST https://api.flood.io/floods \
 -H "Accept: application/vnd.flood.v2+json" \
 -F "flood[tool]=flood-chrome" \
 -F "flood[threads]=1" \
 -F "flood[privacy]=public" \
 -F "flood[name]=ElementTest" \
 -F "flood[tag_list]=shakout" \
 -F "flood[meta]=$meta" \
 -F "flood_files[]=@$TYPESCRIPT_URL" \
 -F "flood[grids][][infrastructure]=demand" \
 -F "flood[grids][][instance_quantity]=1" \
 -F "flood[grids][][region]=$FLOOD_REGION" \
 -F "flood[grids][][instance_type]=$FLOOD_INST_TYPE" \
 -F "flood[grids][][stop_after]=60" | jq -r ".uuid" )

# Wait for flood to finish
echo ">>> [$(date +%FT%T)+00:00] Waiting for flood $flood_uuid"
while [ $(curl --silent --user $FLOOD_API_TOKEN: https://api.flood.io/floods/$flood_uuid | \
  jq -r '.status == "finished"') = "false" ]; do
  echo -n "."
  sleep 3
done

# Get the summary report
flood_report=$(curl --silent --user $FLOOD_API_TOKEN: https://api.flood.io/floods/$flood_uuid/report | \
  jq -r ".summary")

echo
echo ">>> [$(date +%FT%T)+00:00] Detailed results at https://flood.io/$flood_uuid"
echo "$flood_report"

# Optionally store the CSV results
echo
echo ">>> [$(date +%FT%T)+00:00] Storing CSV results at results.csv"
curl --silent --user $FLOOD_API_TOKEN: https://api.flood.io/floods/$flood_uuid/result.csv > result.csv

