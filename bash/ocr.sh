#!/usr/bin/env bash

# ocr.sh
# To convert the latest image file
# explained in https://wilsonmar.github.io/tesseract

SHELL_FILE="out.sh"

   if command -v tesseract ; then  # can't reach.
      # if installed already in /usr/local/bin
         echo "Installing tesseract ..."
         brew install tesseract --HEAD
         pip install pytesseract
   fi
   tesseract -v


#if [ ! -f "${SHELL_FILE}" ]; then
#   echo "Creating symbolic link ..."
#   ln -s source_file "${SHELL_FILE}"
#   ls -l "${SHELL_FILE}"
#fi

# TODO: if a parameter $1 is provided, process that instead

# Get the latest file in folder:
INFILE="ls -Art | tail -n 1"
rm out.txt
tesseract "${INFILE}" out
cat out.txt
