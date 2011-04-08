#!/bin/bash

killall -s USR2 tcpdump # Kill all curently running tcpdump calls

tcpdump -i any -nn > ./testlogfile.txt & 

python trafficStats.py ../teams.cfg testlogfile.txt 


