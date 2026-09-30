#!/bin/sh
# e.g. ultrakill.sh steam

VICTIM=$1
exec pkill -9 -f -- "$VICTIM"
