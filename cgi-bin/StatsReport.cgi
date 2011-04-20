#!/usr/bin/env python2.6
#This file is used to update the Statitistics by querying the Database
#and getting each line in the database with the next sequencial
#time stamp. It then prints the stats in a xml format in which 
#the caller of the file will parse.


import sys
sys.path.append("../database")
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

#gets the traffic stats from the database
stats = dbwrapper.getStats(timestamp)

if stats != 0:

	#get the latest time stamp in the table
	latest_timestamp = stats[0][1]

        #The beggining of the XML to send off
	print "Content-Type: application/xml\n"
	print "<Statistics timestamp=\""+str(latest_timestamp)+"\">"

	#Start up a counter for the while loop below
	count = 0

	#Get the size of the stats table
	statsSize = len(stats) 

	teamList = [""]

	#Loop through the list of stats and build XML to send off
	while (count < statsSize):
		try:
			teamList.index(str(stats[count][2])) # Checks to see whether stats for the team have already been printed.
			break # Stats have been printed so we are done
		except:
			teamList.insert(count,str(stats[count][2])) # Stats have not been printed for the team
			
			print "<team name=\"" + str(stats[count][2]) + "\">"
			print "<incoming traffic=\"" + str(stats[count][3]) + "\"/>"
			print "<outgoing traffic=\"" + str(stats[count][4]) + "\"/>"
			print "<total traffic=\"" + str(stats[count][5]) + "\"/>"
			print "</team>"
			count=count + 1 

	print "</Statistics>"
else:
	print "Content-Type: application/xml\n"
	print "<Statistics timestamp=\"" + str(timestamp) + "\">"
	print "</Statistics>"
