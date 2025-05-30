#!/bin/zsh

# delay the start of conky in daemon mode
killall conky
conky -d --pause 15

# use the powersave cpu governor
./cpu_governor_powersave.sh
