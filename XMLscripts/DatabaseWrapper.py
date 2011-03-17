#!/usr/bin/env python2.6
'''
This is a simple wrapper to the MYSQLdb module that will allow you to easily add new events to the database when they happen. It is easily extensible 
and can be modified to fit any futher needs we have.

You must have MYSQLdb installed in order for this to work, for more instructions on installing MYSQLdb, look at http://www.kitebird.com/articles/pydbapi.html

Once you have installed MYSQLdb you simply need to import this file, create a new dbconnect object (passing in the host IP for the database), 
call the login function (passing it username, password, and database schema (currently we are using cyberstorm for this), and then simply call addEvent anytime you
need to add a new event to the database.
'''
import sys
import MySQLdb

class dbconnect:
	
	#Constructor, requires host IP of databse as a parameter
	def __init__(self, host):
		self.host = host
	
	#Logs into the server with the Username and password provided. 3rd parameter is the default schema.
	def login(self,un,pw,db):
		self.un=un
		self.pw=pw
		self.db=db        
		try:
			self.conn = MySQLdb.connect (host = self.host,
							   user =  self.un,
							   passwd =  self.pw,
							   db =  self.db)
		except MySQLdb.Error, e:
			print "Error %d: %s" % (e.args[0], e.args[1])
			sys.exit (1)
			
	#Closes Database Connection and commits changes
	def close(self):
		self.conn.commit()
		self.conn.close()
			
	#Add an event to the database. Pass in team nae, type of event, number of points awarded (can be negative), time event occured (currently requires format YYYY-MM-DD HH:MM:SS but can be changed to UTC if that is preferable), and the message to be displayed
	def addEvent(self, team_name, type, points, time, message):
		try:
			#Get cursor for query execution
			cursor = self.conn.cursor ()
			
			#Get Team ID from team name
			cursor.execute ("SELECT team_id FROM teams t WHERE team_name =  %s;", (team_name,))
			row=curser.fetchone()
			team_id = row[0]
			
			#Insert into Events table with given information.
			print query
			cursor.execute ("INSERT INTO events (team_id,type,points,timestamp,message) VALUES (%d,%s,%d,%s,%s);" , (team_id,type,points,time,message))
		
			#Update score in team table.
			cursor.execute ("UPDATE teams SET score = score + %d;", (points,))
			
			#Close the cursor after you are done with it.
			cursor.close ()            
	
		#Catch and print any SQL errors that occur then discontinue execution.
		except MySQLdb.Error, e:
			print "Error %d: %s" % (e.args[0], e.args[1])
			sys.exit (1)

	#Add an event to the database. Pass in team nae, type of event, number of points awarded (can be negative), time event occured (currently requires format YYYY-MM-DD HH:MM:SS but can be changed to UTC if that is preferable), and the message to be displayed
	def addStats(self, RtB, BtR, White,BtW,RtW,timestamp):
		try:
			#Get cursor for query execution
			cursor = self.conn.cursor ()

			query = "INSERT INTO stats (RtB,BtR,White,BtW,RtW,assoc_timestamp) VALUES (\"" + RtB + "\",\"" + BtR + "\",\"" + White + "\",\"" + BtW + "\",\"" + RtW + "\"," + str(timestamp) + ");" 
			#Insert into Stats table with given information.
			print query
			cursor.execute (query)
		
			#Close the cursor after you are done with it.
			cursor.close ()            
	
		#Catch and print any SQL errors that occur then discontinue execution.
		except MySQLdb.Error, e:
			print "Error %d: %s" % (e.args[0], e.args[1])
			sys.exit (1)

	#Add an attack to the database. Pass in 
	def addAttack(self, src, srcteam, dest, destTeam, atype, time, timetodie, timestamp):
		try:
			#Get cursor for query execution
			cursor = self.conn.cursor ()
			query = "INSERT INTO attacks (source,source_team,destination,destTeam,type,time,timetodie,assoc_timestamp) VALUES (\"" + src + "\",\"" + srcteam + "\",\"" + dest + "\",\"" + destTeam + "\",\"" + atype + "\",\"" + time + "\",\"" + timetodie + "\"," + str(timestamp) + ");" 

			#Insert into attacks table with given information.
			print query
			cursor.execute (query)
		
			#Close the cursor after you are done with it.
			cursor.close ()            
	
		#Catch and print any SQL errors that occur then discontinue execution.
		except MySQLdb.Error, e:
			print "Error %d: %s" % (e.args[0], e.args[1])
			sys.exit (1)

	#Add an node to the database. Pass in 
	def addNodeStats(self, address, team, os, services, ntype):
		try:
			#Get cursor for query execution
			cursor = self.conn.cursor ()
			query = "INSERT INTO nodestats (address,team,os,nodeType,services) VALUES (\"" + address + "\",\"" + team + "\",\"" + os + "\",\"" + ntype + "\",\"" + services + "\");" 
			
			#Insert into attacks table with given information.
			print query
			cursor.execute (query)
		
			#Close the cursor after you are done with it.
			cursor.close ()            
	
		#Catch and print any SQL errors that occur then discontinue execution.
		except MySQLdb.Error, e:
			print "Error %d: %s" % (e.args[0], e.args[1])
			sys.exit (1)

	#get Stats
	def getStats(self,timestamp):
		try:
			#Get cursor for query execution
			cursor = self.conn.cursor()
			query = "SELECT * FROM stats WHERE assoc_timestamp > '" + timestamp + "' ORDER BY idstats DESC;"

			#Insert into attacks table with given information.
			success = cursor.execute (query)
			
			if success:
				return cursor.fetchall()
			else:
				return 0

			#Close the cursor after you are done with it.
			cursor.close ()            
		
		#Catch and print any SQL errors that occur then discontinue execution.
		except MySQLdb.Error, e:
			print "Error %d: %s" % (e.args[0], e.args[1])
			sys.exit (1)

	#get list of attacks
	def getAttacks(self, timestamp):
		try:
			#Get cursor for query execution
			cursor = self.conn.cursor()
			query = "SELECT * FROM attacks WHERE assoc_timestamp > '" + timestamp + "' ORDER BY idattacks DESC LIMIT 30;" 

			#select 10 latest attacks
			success = cursor.execute (query)
			
			if success:
				rows = cursor.fetchall()

				if len(rows) > 0:
					return rows
				else:
					return 0
			else:
				return 0

			#Close the cursor after you are done with it.
			cursor.close ()            
		
		#Catch and print any SQL errors that occur then discontinue execution.
		except MySQLdb.Error, e:
			print "Error %d: %s" % (e.args[0], e.args[1])
			sys.exit (1)
			
	#get list of active nodes
	def getNodeStats(self):
		try:
			#Get cursor for query execution
			cursor = self.conn.cursor()
			query = "SELECT * FROM nodestats ORDER BY idnodestats DESC" 

			#select 10 latest attacks
			success = cursor.execute (query)
			
			if success:
				return cursor.fetchall()
			else:
				return 0

			#Close the cursor after you are done with it.
			cursor.close ()            
		
		#Catch and print any SQL errors that occur then discontinue execution.
		except MySQLdb.Error, e:
			print "Error %d: %s" % (e.args[0], e.args[1])
			sys.exit (1)
			
	#clear old list of nodes
	def clearNodeStats(self):
		try:
			#Get cursor for query execution
			cursor = self.conn.cursor()
			query = "DELETE FROM nodestats;"

			#execute
			cursor.execute (query)

			#Close the cursor after you are done with it.
			cursor.close ()            
		
		#Catch and print any SQL errors that occur then discontinue execution.
		except MySQLdb.Error, e:
			print "Error %d: %s" % (e.args[0], e.args[1])
			sys.exit (1)
			
	#clear old list of attacks
	def clearAttacks(self):
		try:
			#Get cursor for query execution
			cursor = self.conn.cursor()
			query = "DELETE FROM attacks;"

			#execute
			cursor.execute (query)

			#Close the cursor after you are done with it.
			cursor.close ()            
		
		#Catch and print any SQL errors that occur then discontinue execution.
		except MySQLdb.Error, e:
			print "Error %d: %s" % (e.args[0], e.args[1])
			sys.exit (1)
		
		
