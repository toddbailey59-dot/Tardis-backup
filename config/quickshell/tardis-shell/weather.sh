#!/bin/sh
# args: latitude longitude fahrenheit|celsius
lat="$1"
lon="$2"
unit="$3"
curl -s --max-time 10 \
    "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code&temperature_unit=$unit"
