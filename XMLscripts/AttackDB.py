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
import time

#connect to database
dbinfo = config.database
dbwrapper = DatabaseWrapper.dbconnect(dbinfo['host'])
dbwrapper.login(dbinfo['user'], dbinfo['password'],dbinfo['db'])

attackstats = {"src" : "0", "srcteam" : "0", "DestinationIP" : "0", "destTeam" : "0", "Type" : "0", "Time" : "0", "timetodie" : "1234"}
logtimestamp = str(int(time.time()))
dbcleared = 0

if (len(sys.argv) > 1):
	log = open(sys.argv[len(sys.argv) - 1])
else:
	log = open("log1.txt")

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
			
			if line.find("destTeam = ") != -1:
				line = line.replace("destTeam = ", "")
				line = line.replace("\n", "")
				attackstats["destTeam"] = line
			
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
				
			if line.find("timetodie = ") != -1:
				line = line.replace("timetodie = ", "")
				line = line.replace("\n", "")
				attackstats["timetodie"] = line
		else:
			dbwrapper.addAttack(attackstats["src"],attackstats["srcteam"],attackstats["DestinationIP"],attackstats['destTeam'],attackstats["Type"],attackstats["Time"],attackstats['timetodie'],logtimestamp)

log.close()		
dbwrapper.close()
		
