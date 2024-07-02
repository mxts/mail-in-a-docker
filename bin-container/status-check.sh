#!/bin/bash

declare -a arr=(
    25
    53
    80
    443
    465
    587
    993
    995
    4190
    10025
)

## now loop through the above array
for i in "${arr[@]}"; do
    netstat -ln | grep :$i >null
    # or do whatever with individual element of the array
    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo "❌ Port $i has no listener"
    else
        echo "✔️ Port $i has a listener"
    fi
done
