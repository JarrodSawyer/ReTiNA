#!/usr/bin/env python2.6

import sys
import DatabaseWrapper, config
import cgi, cgitb
cgitb.enable()

#get latest timestamp seen by front end in GET variable timestamp
form = cgi.FieldStorage()

try:
	form['timestamp'].value
	timestamp = form['timestamp'].value
except:
	timestamp = "0";

#connect to database
dbinfo = config.database
dbwrapper = DatabaseWrapper.dbconnect(dbinfo['host'])
dbwrapper.login(dbinfo['user'], dbinfo['password'],dbinfo['db'])

stats = dbwrapper.getStats(timestamp)

latest_timestamp = stats[0][1]

print "<Statistics timestamp="+str(latest_timestamp)+">"

count = 0
statsSize = len(stats) 
teamList = [""]

while (count < statsSize):
      	try:
		teamList.index(str(stats[count][2])) # Checks to see whether stats for the team have already been printed. 
	except:
		teamList.insert(count,str(stats[count][2])) # Stats have not been printed for the team
		count=count + 1
	else:
		break # Stats have been printed so we are done
	print "<team name=" + str(stats[count][2]) + ">"
	print "<incoming packets=" + str(stats[count][3]) + "/>"
	print "<outgoing packets=" + str(stats[count][4]) + "/>"
	print "</team>"

print "/Statistics"