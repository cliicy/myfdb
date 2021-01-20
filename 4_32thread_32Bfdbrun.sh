#!/bin/bash

## KV 64 bytes cases

# 4 thread random 
bench_conf=./cfg/benchmark.cfg
# 修改线程数
sed -i s/threads=32/threads=4/g ${bench_conf}

ws_dir=./workload
workload_set="load u100 d50_i50"

# 修改KV size
for i in  ${workload_set};
do
echo $i
sed -i s/fieldlength=32/fieldlength=8/g ${ws_dir}/$i
sed -i s/recordcount=800000000/recordcount=3200000000/g ${ws_dir}/$i
done

sh ./1_prep_dev.sh ${bench_conf}
sh ./2_initdb.sh   ${bench_conf}
sh ./3_run.sh      ${bench_conf}

# 4 thread best.txt
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

############ 32 thread
# 32 thread best.txt 
bench_conf=./cfg/benchmark.cfg
sed -i s/threads=4/threads=32/g ${bench_conf}
sh ./1_prep_dev.sh ${bench_conf}
sh ./2_initdb.sh   ${bench_conf}
sh ./3_run.sh      ${bench_conf}

# 32 thread random
for i in  ${workload_set};
do
echo $i
sed -i s/datacompressed/\#datacompressed/g ${ws_dir}/$i
done

sh ./1_prep_dev.sh ${bench_conf}
sh ./2_initdb.sh   ${bench_conf}
sh ./3_run.sh      ${bench_conf}
