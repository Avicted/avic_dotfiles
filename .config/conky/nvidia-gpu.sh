#!/bin/sh
# nvidia-gpu.sh KEY
#
# Helper for conky.conf's GPU block (NVIDIA GeForce RTX 5080).
# nvidia-smi is comparatively heavy, so a single query is cached and all of
# conky's field reads share it; the cache is refreshed at most every 2 seconds.
# Prints one value for KEY, no trailing newline (so it drops straight into a
# conky ${goto} column).
#
#   KEY      field                    example
#   temp     GPU temperature (°C)     42
#   util     GPU utilisation (%)      37
#   power    board power draw (W)     220
#   fan      fan speed (%)            45
#   gclk     graphics clock (MHz)     2610
#   mclk     memory clock (MHz)       15500
#   vram     used/total              12.3/16.0GB
#   vrampct  VRAM used (%)            77

cache="${TMPDIR:-/tmp}/conky-nvidia-${USER}.cache"

# Refresh if missing/empty or older than 2 s.
now=$(date +%s)
mtime=$(stat -c %Y "$cache" 2>/dev/null || echo 0)
if [ ! -s "$cache" ] || [ "$((now - mtime))" -ge 2 ]; then
    nvidia-smi \
        --query-gpu=temperature.gpu,utilization.gpu,memory.used,memory.total,power.draw,fan.speed,clocks.gr,clocks.mem \
        --format=csv,noheader,nounits > "$cache" 2>/dev/null
fi

awk -F', *' -v k="$1" 'NR==1{
    if      (k=="temp")    printf "%s", $1
    else if (k=="util")    printf "%s", $2
    else if (k=="power")   printf "%.0f", $5
    else if (k=="fan")     printf "%s", $6
    else if (k=="gclk")    printf "%s", $7
    else if (k=="mclk")    printf "%s", $8
    else if (k=="vram")    printf "%.1f/%.1fGB", $3/1024, $4/1024
    else if (k=="vrampct") printf "%.0f", 100*$3/$4
}' "$cache"
