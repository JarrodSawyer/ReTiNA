#!/bin/bash

####################################################
# Updated by: Jarrod Sawyer
# Date: April 27, 2011
# 
# Installs all packages needed by ReTiNA to run.
# Must be run as root
####################################################


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
ping -qc1 72.14.204.99 > /dev/null && rec=1 # Makes sure there is an Internet connection
if [ $rec -eq 0 ]; then
	echo "Error: No internet connection" | tee install.log
	echo " Check internet connection or manually install packages" | tee isntall.log
	echo "Aborting" | tee install.log
	exit 1
fi

pkgs=(	"snort" 
	"since"
	"nmap"
	"tcpdump"
	"python"
	"mysql-server"
	"apache2"
	"phpmyadmin"
	"python-mysqldb"
)

if [ "$1" == "download" ]; then # Checks if the command line argument is download.
	for package in $pkgs; do
		echo "$dlpkmgr $package"
		$dlpkmgr $package
	done
fi

if [ "$1" == "build" ]; then  # Checks if the command line argument is build.
	#for package in $pkgs; do
		$bldpkmgr ${pkgs[@]}
#	done

# Moves all of the ReTiNA specific Snort files to the correct directory
	if [ -e /etc/snort/snort.conf ]; then # Replaces default Snort.conf with the ReTiNA specific snort.conf
		mv /etc/snort/snort.conf /etc/snort/snort.conf.old
		cd /etc/snort
		ln -s $cdir/snort/snort.conf # Links the ReTiNA snort.conf
	else
		echo "Error: Could not find snort.conf in /etc/snort" | tee install.log
		echo " Check AttackDetection/README for details on configuring snort" | tee install.log
	fi
	
	# Replaces default threshold.conf with the ReTiNA specific threshold.conf
	if [ -e /etc/snort/threshold.conf ]; then
		mv /etc/snort/threshold.conf /etc/snort/threshold.conf.old
		cd /etc/snort
		ln -s $cdir/snort/threshold.conf # Links the ReTiNA threshold.conf
	else
		echo "Error: Could not find threshold.conf in /etc/snort" | tee install.log
		echo " Check AttackDetection/README for details on configuring snort" | tee install.log
	fi

	# Replaces default Snort rules folder with the ReTiNA specific rules folder
	if [ -e /etc/snort/rules ]; then
		mv /etc/snort/rules /etc/snort/rules.old
		cd /etc/snort
		ln -s $cdir/snort/rules
	else
		echo "Error: Could not find snort rules in /etc/snort" | tee install.log
		echo " Check AttackDetection/README for details on configuring snort" | tee install.log
	fi

	# Replaces default (if exists) Snort preproc_rules folder with the ReTiNA specific preproc_rules folder
	if [ -e /etc/snort/preproc_rules ]; then # If folder exists replace it.
		mv /etc/snort/preproc_rules /etc/snort/preproc_rules.old
		cd /etc/snort
		ln -s $cdir/snort/preproc_rules
	else # If the snort folder exists replace the preproc_rules folder... if not snort needs to be installed
	    if [ -e /etc/snort ]; then
		cd /etc/snort
		ln -s $cdir/snort/preproc_rules
	    else
		echo "Error: Could not find snort folder" | tee install.log
		echo " Check AttackDetection/README for details on configuring snort" | tee install.log
	    fi
	fi
fi
