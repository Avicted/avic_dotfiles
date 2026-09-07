#!/bin/bash
# Used memory %, based on MemAvailable (matches `free`/htop), not the
# traditional MemTotal-MemFree calculation conky's built-in ${memperc} uses,
# which counts reclaimable buffers/cache as "used".
awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{printf "%d", (t-a)*100/t}' /proc/meminfo
