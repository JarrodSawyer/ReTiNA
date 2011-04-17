#!/bin/bash

snortOutputPath="/home/sawyer/Desktop/"
snortConfPath="/etc/snort/snort.conf"
teamsConfPath="../teams.cfg"
snortOutputFilePath="/home/sawyer/Desktop/alert.fast"

echo "Starting snort..."
snort -q -i any -b -l "$snortOutputPath" -c "$snortConfPath" 'not src host 10.0.0.1 && not src host 10.0.1.1 && not src host 10.0.2.1' &
sleep 10

echo "running attackStats"

while true
do
    since $snortOutputFilePath | python AttackStats.py "$teamsConfPath"
    sleep 5
done 