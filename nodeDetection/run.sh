#!/bin/bash

i=0

#rm *.cache
while [ 1 ];
do
	let "i++"
	echo "Checking for nodes ($i)..."
	./nmapNodeDet.sh
	echo "***************"
	echo "Updating DB/log ($i)..."
	echo "***************"
	python NodeDB.py log/nodeLog.log
	sleep 5
done
