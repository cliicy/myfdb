#!/bin/bash

bench_conf=./cfg/benchmark.cfg
cp ./cfg/66_foundationdb.conf ./cfg/foundationdb.conf
sh ./1_prep_dev.sh ${bench_conf}
sh ./2_initdb.sh   ${bench_conf}
sh ./3_run.sh      ${bench_conf}
