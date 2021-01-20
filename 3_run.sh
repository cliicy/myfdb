#! /bin/bash

cfg_file=$1
if [ "${cfg_file}" = "" ]; then echo -e "Usage:\n\t3_run.sh cfg_file"; exit 1; fi
if [ ! -e ${cfg_file} ]; then echo "can't find configuration file [${cfg_file}]", exit 2; fi
source ${cfg_file}

# output_dir will be used in fio.sh, so make it global
if [ "${output_dir}" == "" ];
then
        export output_dir=${result_dir}/ycsb-`date +%Y%m%d_%H%M%S`${case_id}
fi

echo "test output will be saved in ${output_dir}"
if [ ! -e ${output_dir} ]; then mkdir -p ${output_dir}; fi

# collect MySQL startup options / configuration / test script
cp $0 ${output_dir}
cp ${cfg_file} ${output_dir}
cp ${app_cfg} ${output_dir}
cp ${app_cfg} ${output_dir}/etc.${app_cfg##*/}

fdbcli --exec 'status' > ${output_dir}/fdbstatus

source ../lib/common-lib
source ../lib/bench-lib

collect_sys_info ${output_dir} ${css_status}

echo "export output_dir=${output_dir}" > ./output.dir
#collect some extra information

echo "will run workload(s) ${workload_set}"
for workload in ${workload_set};
    do
        echo "run workload ${workload}"
	cmd="run"
        # workload friendly name. it will be used in fio.sh, so make it global
        export workload_fname=${workload}
        echo ${workload} | grep load
	if [ $? -eq 0 ]; then cmd="load"; fi
        echo -e "sfx_message starts at: " `date +%Y-%m-%d\ %H:%M:%S` "\n"  > ${output_dir}/${workload_fname}.sfx_message
        sudo chmod 666 /var/log/sfx_messages;
	tail -f -n 0 /var/log/sfx_messages >> ${output_dir}/${workload_fname}.sfx_message &
        echo $! > ${output_dir}/tail.${workload_fname}.pid
        echo "iostat start at: " `date +%Y-%m-%d\ %H:%M:%S` > ${output_dir}/${workload_fname}.iostat
        tail -f -n 0 ${app_dbglog} > ${output_dir}/${workload_fname}.${app}.log &
        echo $! > ${output_dir}/tail.${workload_fname}.${app}.log.pid
        # try to keep existing result file
        if [ -e ${output_dir}/${workload_fname}.result ];
        then
                mv ${output_dir}/${workload_fname}.result ${output_dir}/${workload_fname}-`date +%Y%m%d_%H%M%S`.result
        fi
        echo "${workload_fname} starts at: " `date +%Y-%m-%d\ %H:%M:%S` > ${output_dir}/${workload_fname}.result

        iostat -txdmc ${rpt_interval} ${disk} >> ${output_dir}/${workload_fname}.iostat &
        echo $! > ${output_dir}/${workload_fname}.iostat.pid

        #iostat -txdmc ${rpt_interval} ${logdisk} >> ${output_dir}/${workload_fname}.logdisk.iostat &
        #echo $! > ${output_dir}/${workload_fname}.logdisk.iostat.pid

	cp ./workload/${workload} ${output_dir}
      
	# run ycsb workload, all parameters are from case-cfg/cfg_file
        cp ./workload/${workload} ${output_dir}

#     	(time ${ycsb_dir}/bin/ycsb ${cmd} ${app} -s -threads ${threads} -p status.interval=${rpt_interval} -p foundationdb.batchsize=${batchsize} \
#              	-P ./workload/${workload} -p ${app}.dir=${app_datadir}  -p foundationdb.clusterfile=${fdb_cluster} \
#                -p foundationdb.apiversion=${api_version} >> ${output_dir}/${workload_fname}.result 2>&1) 

        sudo sfx-nvme sfx smart-log-add ${disk} > ${output_dir}/${workload_fname}.smtadd_data_${dev_id}_1
        #sudo fstrim ${mnt_point}
        #sudo sfx-nvme sfx smart-log-add ${logdisk} > ${output_dir}/${workload_fname}.smtadd_log_${fdblog_id}_1
        #sudo fstrim ${log_mnt_point}

     	(time ${ycsb_dir}/bin/ycsb ${cmd} ${app} -s -threads ${threads} -p status.interval=${rpt_interval} -p foundationdb.batchsize=${batchsize} \
              	-P ./workload/${workload} -p ${app}.dir=${app_datadir}  -p foundationdb.clusterfile=${fdb_cluster} \
                 >> ${output_dir}/${workload_fname}.result 2>&1) 

        echo -e "\nsfx_messages ends at: `date +%Y-%m-%d_%H:%M:%S`\n"  >> ${output_dir}/${workload_fname}.sfx_message
        echo ${output_dir}/tail.${workload_fname}.pid
        kill `cat ${output_dir}/tail.${workload_fname}.pid`
        rm -f ${output_dir}/tail.${workload_fname}.pid
        echo -e "\niostat ends at: " `date +%Y-%m-%d_%H:%M:%S` >> ${output_dir}/${workload_fname}.iostat
        echo -e "\n${workload_fname}" "\nends at: " "`date +%Y-%m-%d_%H:%M:%S`" >> ${output_dir}/${workload_fname}.result
        echo ${output_dir}/${workload_fname}.iostat.pid
        kill `cat ${output_dir}/${workload_fname}.iostat.pid`
        #kill `cat ${output_dir}/${workload_fname}.logdisk.iostat.pid`
        rm -f ${output_dir}/${workload_fname}.iostat.pid
        #rm -f ${output_dir}/${workload_fname}.logdisk.iostat.pid
        kill `cat ${output_dir}/tail.${workload_fname}.${app}.log.pid`
        rm -f ${output_dir}/tail.${workload_fname}.${app}.log.pid
        du --block-size=1G ${app_datadir} > ${output_dir}/${workload_fname}.dbsize

        sudo sfx-nvme sfx smart-log-add ${disk} > ${output_dir}/${workload_fname}.smtadd_data_${dev_id}_2
        sudo fstrim ${mnt_point}
        #sudo sfx-nvme sfx smart-log-add ${logdisk} > ${output_dir}/${workload_fname}.smtadd_log_${fdblog_id}_2
        #sudo fstrim ${log_mnt_point}

        cat /sys/block/${dev_id}/sfx_smart_features/sfx_capacity_stat >> ${output_dir}/${workload_fname}.dbsize
        sleep ${sleep_after_case}
    done

ssd_name=$(basename "$PWD")
generate_csv ${output_dir}
get_dbsize_new ${output_dir}
fdb_benchinfo ${output_dir} ${ssd_name}
