#!/bin/bash

killall -s USR2 tcpdump # Kill all curently running tcpdump calls

tcpdump -i any -nn | python trafficStats.py ../teams.cfg 

sleep 5




