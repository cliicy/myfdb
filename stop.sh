#!/bin/bash

sudo service foundationdb stop

for i in {1..100};
do
    ps aux | grep -v grep | grep -e /usr/sbin/fdbserver
    if [ $? -ne 0 ]; then echo stopped; sleep 10; break; fi
    echo "waiting for fdb to exit"
    sleep 3
done
