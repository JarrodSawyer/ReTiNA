#!/usr/bin/env python2.6
#
#  xmlNodeGenerator.py
#  
#
#  Authors: Del Jackson and Daniel Sawyer
#  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
#
# 

import sys
import DatabaseWrapper, config

#connect to database
dbinfo = config.database
dbwrapper = DatabaseWrapper.dbconnect(dbinfo['host'])
dbwrapper.login(dbinfo['user'], dbinfo['password'],dbinfo['db'])

dbwrapper.clearNodeStats()

nodestats = {"Address" : "", "Team" : "", "OS" : "", "Type" : "unknown"}
ServiceList = ""

if (len(sys.argv) > 1):
	log = open(sys.argv[len(sys.argv) - 1])
	
else:
	print "Using default file: sampleNDOut.txt"
	log = open("sampleNDOut.txt")
	
for line in log:
	if line != "\n":
		if line.find("IP: ") != -1:
			line = line.replace("IP: ", "")
			line = line.replace("\n", "")
			nodestats["Address"] = line
			
		if line.find("Team: ") != -1:
			line = line.replace("Team: ", "")
			line = line.replace("\n", "")
			nodestats["Team"] = line
			
		if line.find("OS: ") != -1:
			line = line.replace("OS: ", "")
			line = line.replace("\n", "")
			nodestats["OS"] = line
			
		if line.find("Service: ") != -1:
			line = line.replace("Service: ", "")
			line = line.replace("\n", "")
			ServiceList += line + ","
			
		if line.find("Type: ") != -1:
			line = line.replace("Type: ", "")
			line = line.replace("\n", "")
			nodestats["Type"] = line
			
	else:
		#take off extra comma
		if len(ServiceList) > 0:
			ServiceList = ServiceList[0:len(ServiceList)-1]	

		#insert into database
		dbwrapper.addNodeStats(nodestats['Address'],nodestats['Team'],nodestats['OS'],ServiceList,nodestats['Type'])
		ServiceList = ""
		nodestats = {"Address" : "", "Team" : "", "OS" : "", "Type" : "unknown"}

log.close()
dbwrapper.close()
		


