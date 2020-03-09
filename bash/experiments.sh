#!/usr/bin/env bash

set -e

BASHFILE="~/.bash_profile"

            if grep -q "PATH" "${BASHFILE}" ; then
               echo "rbenv init  already in ${BASHFILE}"
            else
               echo "Adding rbenv init - in ${BASHFILE} "
               # shellcheck disable=SC2016 # Expressions don't expand in single quotes, use double quotes for that.
               # echo "eval \"$( rbenv init - )\" " >>"${BASHFILE}"
               # source "${BASHFILE}"
            fi
            # This results in display of rbenv().

echo "end"