#!/bin/sh
# e.g. ultrakill.sh steam

VICTIM=$1
kill -9 $(ps ax|grep "$VICTIM" | awk -F"\ " '{ print $1 }')
