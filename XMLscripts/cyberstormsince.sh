#!/bin/bash

i=0

echo "Starting snort..."
snort -q -i any -b -l /home/cyberstorm/cyberstorm/realtime-backend/XMLscripts -c /etc/snort/snort.conf 'not src host 10.0.0.1 && not src host 10.0.1.1 && not src host 10.0.2.1' &
sleep 30

echo "Parsing log..."
perl snortlogextraction.pl >> logextraction &
sleep 2

echo "Generating XML..."
while [ true ];
do
#	snort -l ~ -r /root/repo/hackfest/hackfest-realtime/snort/snort.log.1271252877 -b -c /etc/snort/snort.conf
	let "i++"
	echo "Checking for attacks ($i)..."
	since logextraction > log1.txt
	python AttackDB.py
	sleep 4 
done
