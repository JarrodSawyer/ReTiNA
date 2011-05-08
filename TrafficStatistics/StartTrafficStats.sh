#!/bin/bash

########################################################################
# Author: Jarrod Sawyer
# Date: 4/12/2011
#
# Starts the Traffic Statistics module. Kills all of the
# currently running tcpdump calls and the starts tcpdump
# piping the output to the traffic statistics script (trafficStats.py)
# The trafficStats script must be ran with the teams.cfg as an argument.
#########################################################################

killall -s USR2 tcpdump # Kill all curently running tcpdump calls

tcpdump -i any -nn | python trafficStats.py ../teams.cfg # Starts the Traffic Stats script

sleep 5




