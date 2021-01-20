#!/bin/bash

cfg_file=$1
if [ "$1" = "" ]; then echo -e "Usage:\n\t2_initdb.sh cfg_file"; exit 1; fi
if [ ! -e ${cfg_file} ]; then echo "can't find configuration file [${cfg_file}]", exit 2; fi
source ${cfg_file}

sudo cp ${app_cfg} ${fdb_cfgdir}

sudo service foundationdb start
sleep 1
#fdbcli --exec 'configure single new ssd'
#fdbcli --exec 'configure single new ssd-redwood-experimental'
fdbcli --exec 'configure single new ssd-redwood-experimental'
#fdbcli --exec 'configure storage=46'
