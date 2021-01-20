#!/bin/bash

# 4 thread best
bench_conf=./cfg/benchmark.cfg
sed -i s/threads=32/threads=4/g ${bench_conf}
sh ./1_prep_dev.sh ${bench_conf}
sh ./2_initdb.sh   ${bench_conf}
sh ./3_run.sh      ${bench_conf}

# 4 thread random
# default random source data
ws_dir=./workload
workload_set="load u100 d50_i50"
for i in  ${workload_set};
do
echo $i
sed -i s/datacompressed/\#datacompressed/g ${ws_dir}/$i
done

sh ./1_prep_dev.sh ${bench_conf}
sh ./2_initdb.sh   ${bench_conf}
sh ./3_run.sh      ${bench_conf}
