#!/bin/bash

snortOutputPath="/home/sawyer/Desktop/"               # Path to ouput the log files
snortConfPath="/etc/snort/snort.conf"                 # Path to the snort config file to use
teamsConfPath="../teams.cfg"                          # Path to config files containing teams IP addresses
snortOutputFilePath="/home/sawyer/Desktop/alert.fast" # Path to output the alert.fast file needed for correct parsing

echo "Starting snort..."
snort -q -i any -b -l "$snortOutputPath" -c "$snortConfPath" 'not src host 10.0.0.1 && not src host 10.0.1.1 && not src host 10.0.2.1' &
sleep 10 # Sleep for 10 seconds

echo "running attackStats"

while true  # Run the parsing python script to parse out snorts output
do
    since $snortOutputFilePath | python AttackStats.py "$teamsConfPath" #Parses only the new data that has been inserted to the log file per loop
    sleep 5
done 
