#!/usr/bin/env bash

# https://stackoverflow.com/questions/39596446/how-to-get-gpg-public-key-in-bash

RESPONSE=$( gpg --list-secret-keys --keyid-format LONG | grep sec )
   # secLine="sec rsa2048/62C414BA89BFBE52 2020-03-01 [SC] [expires: 2022-03-01]"
NAMEZ=${RESPONSE##*/}  # retain the part after the last slash
   # 62C414BA89BFBE52 2020-03-01 [SC] [expires: 2022-03-01]
#echo $NAMEZ

KeyVal=$( echo ${RESPONSE##*/} | cut -d " " -f 1 )
echo $KeyVal
exit

KeyVal=${NAMEZ% *}  # retain the part before the space
echo $KeyVal
exit

YO=""
KeyVal=$( gpg --list-keys | awk '/sec/{if (length($2) > 0) print $2}' )
echo $KeyVal

exit
echo "${keyVal##*/}"

# keyVal=$(gpg --list-keys | awk '/sub/{if (length($2) > 0) print $2}'); echo "${keyVal##*/}"
gpg --list-secret-keys --keyid-format LONG | grep sec | grep -o -P '(?<=/)[A-Z0-9]{8}'
# ; echo "${keyVal##*/}"
echo $RESPONSE