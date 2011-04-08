#!/bin/bash

snortOutputPath="/home/sawyer/workspace/ReTiNA/XMLscripts"
snortConfPath="/etc/snort/snort.conf"
teamsConfPath="../teams.cfg"
snortOutputFilePath="./alert.fast"

echo "Starting snort..."
snort -q -i any -b -l "$snortOutputPath" -c "$snortConfPath" 'not src host 10.0.0.1 && not src host 10.0.1.1 && not src host 10.0.2.1' &
sleep 30

python AttackStats.py "$teamsConfPath" "$snortOutputFilePath" 