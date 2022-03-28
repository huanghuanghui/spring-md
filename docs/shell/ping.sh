#!/bin/bash

for ip in 192.168.1.{0..2} ; do
    echo ping $ip
    ping $ip -c 2
    if [ $? -eq 0 ]; then
        echo $ip is live
        else
          echo $ip is not alive
    fi
done