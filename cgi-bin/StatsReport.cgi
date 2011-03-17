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

if stats != 0:
	latest_timestamp = stats[0][6]

	print "Content-Type: application/xml\n"
	print "<Statistics timestamp=\"" + str(latest_timestamp) + "\">"

	b2r = 0
	b2w = 0
	r2b = 0
	r2w = 0
	white = 0
	for s in stats:
		b2r += int(s[1])
		r2b += int(s[2])
		white += int(s[3])
		r2w += int(s[4])
		b2w += int(s[5])
	print "\t<stat BluetoRed=\"" + str(b2r) + "\" RedtoBlue=\"" + str(r2b) + "\" White=\""+ str(white) + "\" RedtoWhite=\"" + str(r2w) + "\" BluetoWhite=\""  + str(b2w) + "\"/>"
	print "</Statistics>"

else:
	print "Content-Type: application/xml\n"
	print "<Statistics timestamp=\"" + str(timestamp) + "\">"
	print "</Statistics>"
