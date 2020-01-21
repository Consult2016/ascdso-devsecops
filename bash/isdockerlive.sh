#!/bin/bash
# isdockerlive.sh
# https://gist.github.com/peterver/ca2d60abc015d334e1054302265b27d9
# https://medium.com/@valkyrie_be/quicktip-a-universal-way-to-check-if-docker-is-running-ffa6567f8426
rep=$(curl -s --unix-socket /var/run/docker.sock http://ping > /dev/null)
status=$?

if [ "$status" == "7" ]; then
    echo 'not connected'
    exit 1
fi

echo 'connected'
exit 0