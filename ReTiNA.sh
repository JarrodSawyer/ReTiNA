#!/bin/bash

##################################################
# Updated by: Jarrod Sawyer
# Date: April 27, 2011
#
# Starts the ReTiNA system. The script must be 
# run as root.
#
##################################################

curUser=`whoami`
if [ "$curUser" != "root" ]; then # Checks to make sure the script is run as root.
	echo "Error: must be run as root"
	exit 1
fi

redir="1,2>/dev/null" # Sets the redirect directory
if [ $# -eq 1 -a "$1" == "-d" ]; then
	redir=""
fi
cdir=`pwd`
while [ 0 ]; do
	cd "$cdir/TrafficStatistics" # Start Traffic Statistics
	./StartTrafficStats.sh $redir
	cd "$cdir/NodeDetection" # Start Node Detection
	./StartNodeDetection.sh $redir
	cd "$cdir/AttackDetection" # Start Attack Detection
	./StartAttackDetection.sh $redir
done
