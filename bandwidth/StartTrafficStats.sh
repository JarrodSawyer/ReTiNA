#!/bin/bash

killall -s USR2 iptraf
iptraf -i all -f -B -L ./testlogfile.txt
#sudo chmod a+rw logfile.txt

python trafficStats.py teams.cfg testlogfile.txt 


