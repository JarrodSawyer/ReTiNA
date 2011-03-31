#!/usr/bin/env python2.6
#
#  pythonxmltest.py
#  
#
#  Authors: Del Jackson, Daniel Sawyer
#  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
#

import sys
import DatabaseWrapper, config
import time

#connect to database
dbinfo = config.database
dbwrapper = DatabaseWrapper.dbconnect(dbinfo['host'])
dbwrapper.login(dbinfo['user'], dbinfo['password'],dbinfo['db'])
logtimestamp = str(int(time.time()))

stats = {"RtB" : "0", "BtR" : "0", "BtW" : "0", "RtW" : "0", "White" : "0"}

if (len(sys.argv) > 1):
	log = open(sys.argv[len(sys.argv) - 1])
	print sys.argv[len(sys.argv) - 1]
else:
	log = open("bandwidth.txt")

for line in log:
	if line != "\n":
		if line.find("B2R = ") != -1:
			line = line.replace("B2R = ", "")
			line = line.replace("\n", "")
			stats["BtR"] = line
			
		if line.find("B2W = ") != -1:
			line = line.replace("B2W = ", "")
			line = line.replace("\n", "")
			stats["BtW"] = line
			
		if line.find("R2B = ") != -1:
			line = line.replace("R2B = ", "")
			line = line.replace("\n", "")
			stats["RtB"] = line
			
		if line.find("R2W = ") != -1:
			line = line.replace("R2W = ", "")
			line = line.replace("\n", "")
			stats["RtW"] = line
			
		if line.find("White = ") != -1:
			line = line.replace("White = ", "")
			line = line.replace("\n", "")
			stats["White"] = line
	
	else:
		print "Inserting into DB."
		dbwrapper.addStats(stats["RtB"],stats["BtR"],stats["White"],stats['BtW'],stats['RtW'],logtimestamp)
		stats = {"RtB" : "0", "BtR" : "0", "BtW" : "0", "RtW" : "0", "White" : "0"}

log.close()
dbwrapper.close()
