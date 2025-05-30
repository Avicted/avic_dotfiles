#!/bin/zsh

sudo watch "grep 'cpu MHz' /proc/cpuinfo | awk {'print $4'} | sort -n"
# sudo watch "grep 'cpu MHz' /proc/cpuinfo | awk {'print awk $4'} | grep -o '^[0-9]*' | while read p; do echo "Core MHz: $p"; done | lolcat"
