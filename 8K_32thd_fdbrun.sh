#!/bin/bash

## KV 256 bytes cases

bench_conf=./cfg/benchmark.cfg
# 修改线程数
sed -i s/threads=4/threads=32/g ${bench_conf}

ws_dir=./workload
workload_set="load u100 d50_i50"

sh ./1_prep_dev.sh ${bench_conf}
sh ./2_initdb.sh   ${bench_conf}
sh ./3_run.sh      ${bench_conf}

# 32 thread best.txt
ws_dir=./workload
workload_set="load u100 d50_i50"
for i in  ${workload_set};
do
echo $i
sed -i s/\#datacompressed/datacompressed/g ${ws_dir}/$i
done

sh ./1_prep_dev.sh ${bench_conf}
sh ./2_initdb.sh   ${bench_conf}
sh ./3_run.sh      ${bench_conf}
