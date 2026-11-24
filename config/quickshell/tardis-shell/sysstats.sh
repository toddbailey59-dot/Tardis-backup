#!/bin/sh
# Lightweight system snapshot for the TARDIS shell bar.
load=$(awk '{print $1}' /proc/loadavg 2>/dev/null)
temp=$(cat /sys/class/thermal/thermal_zone*/temp /sys/class/hwmon/hwmon*/temp*_input 2>/dev/null |
    awk 'BEGIN { m = 0 } { if ($1 > m) m = $1 } END { if (m > 1000) printf "%d", m / 1000; else printf "%d", m }')
mem=$(free 2>/dev/null | awk '/^Mem:/ {printf "%d", ($3 / $2) * 100}')
printf '{"load":%s,"temp":%s,"mem":%s}\n' "${load:-0}" "${temp:-0}" "${mem:-0}"
