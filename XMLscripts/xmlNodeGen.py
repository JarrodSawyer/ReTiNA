#!/usr/bin/env python2.3
#
#  xmlNodeGenerator.py
#  
#
#  Authors: Del Jackson and Daniel Sawyer
#  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
#
# 

import sys
sys.path.append("../database")
import DatabaseWrapper, config

#connect to database
db_info = config.database
dbwrapper = DatabaseWrapper.dbconnect(db_info['host'])
dbwrapper.login(db_info['user'], db_info['password'], db_info['db'])

nodestats = {"Address" : "", "Team" : "", "OS" : ""}
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
		
		#using * as end of file signal
		if line.find('*') != -1:
			log.close()
			dbwrapper.close()
			sys.exit (1)
			
	else:
		#take off extra comma
		if len(ServiceList) > 0:
			ServiceList = ServiceList[0:len(ServiceList)-1]	

		#insert into database
		dbwrapper.addNodeStats(nodestats['Address'],nodestats['Team'],nodestats['OS'],ServiceList)
		ServiceList = ""
		nodestats = {"Address" : "", "Team" : "", "OS" : ""}
		


