#!/bin/bash

bench_conf=./cfg/benchmark.cfg
sh ./1_prep_dev.sh ${bench_conf}
sh ./2_initdb.sh   ${bench_conf}
sh ./3_run.sh      ${bench_conf}

#sh 4thread_fdbrun.sh
#sh 4_32thread_32Bfdbrun.sh

#fdb_conf=./cfg/foundationdb.conf
##FF="50 80 90"
#FF="80 90 99"
#for i in  ${FF};
#do
#echo $i
##sed -i s/foundationdb.conf/${i}_foundationdb.conf/g ${fdb_conf} 
#cp ./cfg/${i}_foundationdb.conf ./cfg/foundationdb.conf
#sh ./1_prep_dev.sh ${bench_conf}
#sh ./2_initdb.sh   ${bench_conf}
#sh ./3_run.sh      ${bench_conf}
##sed -i s/${i}_foundationdb.conf/foundationdb.conf/g ${fdb_conf}
#done

