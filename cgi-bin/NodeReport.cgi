#!/usr/bin/env python2.6
#This file is used to update the Nodes by querying the Database
#and getting each line in the database with the next sequencial
#time stamp. It then prints the stats in a xml format in which 
#the caller of the file will parse.

import sys
sys.path.append("../database")
import DatabaseWrapper, config
import time
import math

#connect to database
dbinfo = config.database
dbwrapper = DatabaseWrapper.dbconnect(dbinfo['host'])
dbwrapper.login(dbinfo['user'], dbinfo['password'],dbinfo['db'])


nodes = dbwrapper.getNodeStats()
timestamp = int(math.floor(time.time())) 

print "Content-Type: application/xml\n"
print "<IPList>"

if nodes:
	for node in nodes:
		print "\t<IP Address=\"" + node[1] + "\" Team=\"" + node[2] + "\" OS=\"" + node[3]+ "\" NodeType=\"" + node[4]  + "\">"
	
		print "\t\t<ServiceList>"
	
		if node[5] == "none":
			print "\t\t</ServiceList>"
		else:
			services = node[5].split(',')
			for service in services:
				type_and_status = service.split(' ')
				print "\t\t\t<Service type=\"" + type_and_status[0] + "\" status=\"" + type_and_status[1] + "\"/>"
		
			print "\t\t</ServiceList>"
		
		print "\t</IP>"

print "</IPList>"
