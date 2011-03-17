#!/bin/bash

curUser=`whoami`
if [ "$curUser" != "root" ]; then
	echo "Error: must be run as root"
	exit 1
fi

redir="1,2>/dev/null" 
if [ $# -eq 1 -a "$1" == "-d" ]; then
	redir=""
fi
cdir=`pwd`
while [ 0 ]; do
	cd "$cdir/bandwidth"
	./doit $redir
	cd "$cdir/nodeDetection"
	./run.sh $redir
	cd "$cdir/XMLscripts"
	./cyberstormsince.sh $redir
done
