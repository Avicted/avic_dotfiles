#!/usr/bin/env bash

# delay the start of conky in daemon mode
killall conky
conky -d --pause 15

# use the powersave cpu governor
"$(dirname "$0")/cpu_governor_powersave.sh"
