#!/bin/bash

# Author: Jarrod Sawyer
# Date: 4/20/2011
#
# Runs the node detection module. Starts nodedection and then runs the  
# nodedetection output parsing script. Sleeps for a period and then
# repeats the process.

i=0

while [ 1 ];
do
	let "i++"
	echo "Checking for nodes ($i)..."
	./nmapNodeDet.sh # Run's Node Detection
	echo "***************"
	echo "Updating DB/log ($i)..."
	echo "***************"
	python NodeDB.py log/nodeLog.log # Parse the node detection output file
	sleep 5
done
