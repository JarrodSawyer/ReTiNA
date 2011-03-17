#!/bin/bash

if [ $# -eq 0 ]; then
	echo "Usage: ./install.sh [build|download]"
	exit 1
fi
cdir=`pwd`


[ -e install.log ] &&  rm install.log

if [ -e /usr/bin/apt-get ]; then
	bldpkmgr="apt-get -y install"
	dlpkmgr="apt-get -dy install" 
else
	echo "Error: Unknown package manager" | tee install.log
	echo "Aborting" | tee install.log
	exit 1
fi

rec=0
ping -qc1 72.14.204.99 > /dev/null && rec=1
if [ $rec -eq 0 ]; then
	echo "Error: No internet connection" | tee install.log
	echo " Check internet connection or manually install packages" | tee isntall.log
	echo "Aborting" | tee install.log
	exit 1
fi

pkgs=(	"snort" 
	"libfile-tail-perl"
	"since"
	"perl"
	"nmap"
	"iptraf"
	"python"
	"mysql-server"
	"apache2"
	"phpmyadmin"
	"python-mysqldb"
	"libjs-jquery" 
)

if [ "$1" == "download" ]; then
	for package in $pkgs; do
		echo "$dlpkmgr $package"
		$dlpkmgr $package
	done
fi
if [ "$1" == "build" ]; then	   
	#for package in $pkgs; do
		$bldpkmgr ${pkgs[@]}
#	done
	if [ -e /etc/snort/snort.conf ]; then
		mv /etc/snort/snort.conf /etc/snort/snort.conf.old
		cd /etc/snort
		ln -s $cdir/snort/snort.conf
	else
		echo "Error: Could not find snort.conf in /etc/snort" | tee install.log
		echo " Check README.ATTACKDETECTION for details on configuring snort" | tee install.log
	fi
	if [ -e /etc/snort/threshold.conf ]; then
		mv /etc/snort/threshold.conf /etc/snort/threshold.conf.old
		cd /etc/snort
		ln -s $cdir/snort/threshold.conf
	else
		echo "Error: Could not find threshold.conf in /etc/snort" | tee install.log
		echo " Check README.ATTACKDETECTION for details on configuring snort" | tee install.log
	fi
	if [ -e /etc/snort/rules ]; then
		mv /etc/snort/rules /etc/snort/rules.old
		cd /etc/snort
		ln -s $cdir/snort/rules
	else
		echo "Error: Could not find snort rules in /etc/snort" | tee install.log
		echo " Check README.ATTACKDETECTION for details on configuring snort" | tee install.log
	fi
fi
