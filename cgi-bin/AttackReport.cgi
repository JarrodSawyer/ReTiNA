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


attacks = dbwrapper.getAttacks(timestamp)

if attacks != 0:
	latest_timestamp = attacks[0][8]

	print "Content-Type: application/xml\n"
	print "<attackList timestamp=\"" + str(latest_timestamp) + "\">"


	if attacks != 0:
		for a in attacks:
			print "\t<attack src=\"" + a[1] + "\" srcteam=\"" + a[2] + "\" destIP=\"" + a[3] + "\" destTeam=\"" + a[4] + "\" Type=\"" + a[5] + "\" Time=\"" + a[6] + "\" TimetoDie=\"" + a[7] + "\"/>"

	print "</attackList>"

else:
	print "Content-Type: application/xml\n"
	print "<attackList timestamp=\"" + str(timestamp) + "\">"
	print "</attackList>"








