#!/bin/bash

# root check
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


# default argument check
if [[ -z $1 ]]
then
    echo Usage: ./ml-support-dump.sh \[running time in seconds\]
    echo e.g. ./ml-support-dump.sh 120 \(runs the application for 2 minutes before closing\)
    exit 1
fi


# global vars
TSTAMP=`date +"%H%M%S-%m-%d-%Y"`
INTERVAL=5
TIME=$1
PIDS=(`pidof MarkLogic`)

# main
echo Support script started at: $TSTAMP - running for $TIME seconds
mkdir /tmp/$TSTAMP

while [ $TIME -gt 0 ]; do
	date >> /tmp/$TSTAMP/vmstat
	vmstat >> /tmp/$TSTAMP/vmstat
	date >> /tmp/$TSTAMP/pstack.log
	/etc/init.d/MarkLogic pstack >> /tmp/$TSTAMP/pstack.log
	date >> /tmp/$TSTAMP/pmap.log
	/etc/init.d/MarkLogic pmap >> /tmp/$TSTAMP/pmap.log	

	#pstack summary routine
	for s in ${PIDS[@]}; do
    		date >> /tmp/$TSTAMP/pstack-summary.log	
		echo Stack overview for pid $s >> /tmp/$TSTAMP/pstack-summary.log
		gdb -ex "set pagination 0" -ex "thread apply all bt" -batch -p $s | \
		awk '
		  BEGIN { s = ""; } /Thread/ { print s; s = ""; } /^\#/ { if (s != "" ) { s = s "," $4} else { s = $4 } } END { print s }' | \
		  sort | uniq -c | sort -r -n -k 1,1 >> /tmp/$TSTAMP/pstack-summary.log
		echo Stack overview for pid $s completed >> /tmp/$TSTAMP/pstack-summary.log
	done

	sleep $INTERVAL
	echo -e ". \c"        
        let TIME-=$INTERVAL
done
echo completed

# create zip 
zip -9 -r /tmp/$TSTAMP.zip /tmp/$TSTAMP
echo /tmp/$TSTAMP.zip created
