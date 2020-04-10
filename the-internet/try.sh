#!/usr/bin/env bash
CONTAINER_ID="success7"  # temporary for testing
# if CONTAINER_ID not blank
# write variable variable in a shell file so calling the script retrieves CONTAINER_ID :
# based on https://stackoverflow.com/questions/16618071/can-i-export-a-variable-to-the-environment-from-a-bash-script-without-sourcing-i/16619261
cat >the-internet-docker-CONTAINER_ID.sh <<EOF
#!/bin/bash
# Saved by try.sh
CONTAINER_NAME="jloisel/jpetstore6"
CONTAINER_ID=$( docker ps | grep "$CONTAINER_NAME" | cut -d " " -f 1 )
export CONTAINER_ID="$CONTAINER_ID"
echo "CONTAINER_ID=$CONTAINER_ID"
exec "$@"
# Run this, then run:
# chmod +x ./the-internet-docker-CONTAINER_ID.sh
# ./the-internet-docker-CONTAINER_ID.sh
EOF
