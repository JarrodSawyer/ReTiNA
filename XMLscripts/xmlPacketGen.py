#!/usr/bin/env python2.6
#
#  pythonxmltest.py
#  
#
#  Authors: Del Jackson, Daniel Sawyer
#  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
#

import sys
sys.path.append("../database")
import DatabaseWrapper, config

#connect to database
db_info = config.database
dbwrapper = DatabaseWrapper.dbconnect(db_info['host'])
dbwrapper.login(db_info['user'], db_info['password'], db_info['db'])

attackstats = {"src" : "0", "srcteam" : "0", "DestinationIP" : "0", "Type" : "0", "Time" : "0"}
stats = {"RtB" : "14450", "BtR" : "8999", "White" : "1337"}

if (len(sys.argv) > 1):
	log = open(sys.argv[len(sys.argv) - 1])
else:
	print "Using default file: log2.txt"
	log = open("log2.txt")

for line in log:
	if line != "\n":
		if line.find("sourceip = ") != -1:
			line = line.replace("sourceip = ", "")
			line = line.replace("\n", "")
			attackstats["src"] = line
			
		if line.find("destip = ") != -1:
			line = line.replace("destip = ", "")
			line = line.replace("\n", "")
			attackstats["DestinationIP"] = line
		
		if line.find("teamname = ") != -1:
			line = line.replace("teamname = ", "")
			line = line.replace("\n", "")
			attackstats["srcteam"] = line
			
		if line.find("attacktype = ") != -1:
			line = line.replace("attacktype = ", "")
			line = line.replace("\n", "")
			attackstats["Type"] = line
			
		if line.find("LogTime = ") != -1:
			line = line.replace("logTime", "")
			line = line.replace("\n", "")
			
		if line.find("timestamp = ") != -1:
			line = line.replace("timestamp = ", "")
			line = line.replace("\n", "")
			attackstats["Time"] = line
			
		if line.find("btr = ") != -1:
			line = line.replace("btr = ", "")
			line = line.replace("\n", "")
			stats["BtR"] = line
			
		if line.find("btw = ") != -1:
			line = line.replace("btw = ", "")
			line = line.replace("\n", "")
			
		if line.find("rtb = ") != -1:
			line = line.replace("rtb = ", "")
			line = line.replace("\n", "")
			stats["RtB"] = line
			
		if line.find("rtw = ") != -1:
			line = line.replace("rtw = ", "")
			line = line.replace("\n", "")
			
		if line.find("white = ") != -1:
			line = line.replace("white = ", "")
			line = line.replace("\n", "")
			stats["White"] = line
		
		#using * as end of file signal
		if line.find('*') != -1:
			log.close()
			dbwrapper.close()
			sys.exit (1)
	
	else:
		dbwrapper.addStats(stats["RtB"],stats["BtR"],stats["White"])
		dbwrapper.addAttack(attackstats["src"],attackstats["srcteam"],attackstats["DestinationIP"],attackstats["Type"],attackstats["Time"])
		
