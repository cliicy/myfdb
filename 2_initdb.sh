#!/bin/bash

cfg_file=$1
if [ "$1" = "" ]; then echo -e "Usage:\n\t2_initdb.sh cfg_file"; exit 1; fi
if [ ! -e ${cfg_file} ]; then echo "can't find configuration file [${cfg_file}]", exit 2; fi
source ${cfg_file}

./stop.sh ${cfg_file}

if [ "${app_datadir}" != "" ] && [ ! -e ${app_datadir} ];
then
        sudo mkdir -p ${app_datadir};
fi

#if [ ! -e ${app_dblogdir} ]; then sudo mkdir -p ${app_dblogdir}; fi

sudo chown -R `whoami`:`whoami` ${app_datadir}
#sudo chown -R `whoami`:`whoami` ${app_dblogdir} 

if [ "${app_datadir}" != "" ] && [ ! -e ${app_datadir} ];
then
	rm -rf ${app_datadir}/*
fi

if [ "${app_serverlog}" != "" ] && [ ! -e ${app_serverlog} ];
then
        sudo mkdir -p ${app_serverlog};
fi

for i in $(seq 1 ${fdbins})
do
    if [ "${app_serverlog}${i}" != "" ] && [ ! -e ${app_serverlog}${i} ];
    then
        sudo mkdir -p ${app_serverlog}${i};
    fi
done

if [ "${app_baklog}" != "" ] && [ ! -e ${app_baklog} ];
then
        sudo mkdir -p ${app_baklog};
fi


sudo chown -R `whoami`:`whoami` ${app_datadir}
#sudo chown -R `whoami`:`whoami` ${app_dblogdir}

./start.sh ${cfg_file}

