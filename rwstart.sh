#!/bin/bash

cfg_file=$1
if [ "$1" = "" ]; then echo -e "Usage:\n\t2_initdb.sh cfg_file"; exit 1; fi
if [ ! -e ${cfg_file} ]; then echo "can't find configuration file [${cfg_file}]", exit 2; fi
source ${cfg_file}

sudo cp ${app_cfg} ${fdb_cfgdir}

#${fdbmonitor} --conffile /etc/foundationdb/foundationdb.conf --lockfile ${app_datadir}/fdbmonitor.pid --daemonize &

#echo "${backupagent} --cluster_file ${fdb_cluster} --logdir ${app_baklog}"

#echo "${fdbserver} --class storage --cluster_file ${fdb_cluster} --datadir ${app_serverdata0} --listen_address public --logdir ${app_serverlog} --public_address auto:4500"
#${fdbserver} --class storage --cluster_file ${fdb_cluster} --datadir ${app_serverdata0} --listen_address public --logdir ${app_serverlog} --public_address auto:4500


#${fdbcli} --exec 'configure single new ssd'

sudo service foundationdb start
sleep 1
fdbcli --exec 'configure single new ssd-redwood-experimental'
