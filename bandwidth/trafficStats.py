#!/usr/bin/env python2.6

#Usage: python trafficStats.py teams.cfg logfile.txt
#
#trafficStats takes in two arguments, a teams config file and a IPTraf log file
#We parse out the team info from the config, giving us a list of team names and subnets
#Next we create a list with each item containing team name, an incoming packet counter, and an outgoing packet counter
#We then begin parsing the log file line by line, collecting ip info and packets send
#We increment the corresponding packet counters accordingly
#Periodically we write traffic stats data to the database using a wrapper and reset our packet counters


import sys
import time
import re
sys.path.append("../database")
import DatabaseWrapper
import config

#check for correct number of arguments
if len(sys.argv) != 3:
	print("usage: python trafficStats.py teams.cfg logfile.txt")
	exit();

#check for valid teams config
try:
	#check if the file exists by opening it
	config_file = open(sys.argv[1], 'r')
except IOError:
	#failed to open file
	print('Could not open file: %s' % sys.argv[1])
	exit();

#check for valid traffic stats log
try:
	#check if the file exists by opening it
	log_file = open(sys.argv[2], 'r')
except IOError:
	#failed to open file
	print('Could not open file: %s' % sys.argv[2])
	exit();


#creates a list by parsing a config file, each item of which is a tuple containing team_name and subnet.
#so it will look something like this: [ (white, 10.0.0) , (red, 10.0.1) , (blue, 10.0.2) ]
def createTeamInfoList(config_file):
	
	team_info = [];	#list containing team names and subnets
	
	while 1:
		line = config_file.readline();
		if not line:
			break
		pass 
		space_index = line.find(" ")					#name and subnet are space seperated
		team_name = line[ :space_index ]				#get everything up to space
		team_subnet = line[ space_index+1: ]			#get everything after space
		team_subnet = team_subnet.replace('\n', "")	#remove any newline characters
		team_info.append( (team_name, team_subnet) )	#stores a tuple, ie. (white, 10.0.1)
	return team_info;

#creates a list from team_info, each item of which is a list containing team_name, incoming packets, and outgoing packets
#so it will look something like this: [ [white, 0, 0] , [red, 0, 0] , [blue, 0, 0] ]
def createTeamStatsList(team_info):
	
	team_stats = [];		#list containing team_name, incoming packets, and outgoing packets
	for item in team_info:
		team_stats.append( [item[0], 0, 0, 0] );	#create a list element containing team_name, 0 (incoming), 0 (outgoing), and 0 (outgoingtotal)
	return team_stats

#sets the second and third item of each element of the team_stats list to 0
#we do this after reporting traffic stat data for the current time interval
def resetTeamStats():
	
	global team_stats_list
	for item in team_stats_list:
		item[1:2] = 0;		#reset incoming & outgoing counters to zero. Do not reset Total Outgoing count

#returns the team name that is associated with the given subnet
def getTeamBySubnet(subnet):
	
	global team_info			#make global team_info list locally available
	for item in team_info:
		if item[1] == subnet:	#each list element is a tuple.  First tuple element is team_name, second is team_subnet
			return item[0]
	return -1

#parses out the relevant data from each line of the traffic stats log.
#the input string should look something like this: "10.0.2.10:1108 > 10.0.2.1:38181"
def parseTrafficInfo(ip_to_ip):
	
	if ip_to_ip != "":
		space_index = ip_to_ip.find(" ")			#find the first space
		sender = ip_to_ip[ :space_index ]			#substring out sender ip: "10.0.2.10:1108"
		receiver = ip_to_ip[ (space_index+3): ]		#substring out receiver ip: "10.0.2.1:38181"
		
		sender_subnet = sender[ :sender.rfind(".") ]		#substring relevant subnet info: "10.0.2"
		receiver_subnet = sender[ :receiver.rfind(".") ]
		incrementPacketCount(sender_subnet, 1)		#type 1 increments Incoming packet count
		incrementPacketCount(receiver_subnet, 2)		#type 2 increments Outgoing packet count
		#print("sender: %s"  % sender_subnet);
		#print("receiver: %s" % receiver_subnet);

#add numPackets to the Incoming/Outgoing packet count for the the team with the given subnet
#type = 1 means Incoming, type = 2 means Outgoing
def incrementPacketCount(subnet, type):
	
	global team_info_list		#saves us having to pass these in as parameters
	global team_stats_list
	global numPackets
	team = ""
	if subnet != "":
		for team_item in team_info_list:	#find the team for the given subnet
			if team_item[1] == subnet:
				team = team_item[0]
	if team != "":
		for stats_item in team_stats_list:	#find the stats for the team and add to packet count
			if stats_item[0] == team:
				stats_item[type] += int(numPackets)		#this is where we decide what to increment, Incoming or Outgoing
				if type == 2:	#if we're adding to Outgoing
					stats_item[3] += int(numPackets)		#add to Total Outgoing bytes
				#print(stats_item)

#use the database wrapper to send traffic stats info for each team.
#sent data includes the current timestamp, team_name, incoming packets, and outgoing packets
def pushTrafficStats():
	
	global team_info_list
	global team_stats_list
	print("pushing stats")
	for team_item in team_info_list:
		team_name = team_item[0]
		for stats_item in team_stats_list:
			if stats_item[0] == team_name:
				incoming = stats_item[1]
				outgoing = stats_item[2]
				total_outgoing = stats_item[3]
				now = time.time()
				print("sending stats for team %s" % team_name)
				addStats(now, team_name, incoming, outcoming, total_outgoing)

#main script loop, which reads the traffic stats log one line at a time and finds ip information and number of packets send
#if both numPacks and trafficInfo are found, parseTrafficInfo() is called.  Timestamps are used to regulate how often traffic stats are reported
def parseTrafficStats(log_file):
	
	global loopTime;
	global numPackets;
	start = time.time()	#get a starting time
	while 1:
		line = log_file.readline()
		if not line:
			print("Reached end of log file")
			break;
		pass
		
		packetInfo = re.search( 'length (\d*)', line)	#parse the number of packets send
		#print(packetInfo)
		if packetInfo:
			packetInfo_string = str(packetInfo.group())
			space_index = packetInfo_string.find(" ")
			numPackets = packetInfo_string[ :space_index ]
			if int(numPackets) > 0:	#only continue if there were actually send packets
				trafficInfo = re.search( '(\d*)[.]{1}(\d*)[.]{1}(\d*)[.]{1}(\d*)[:]*(\d*) > (\d*)[.]{1}(\d*)[.]{1}(\d*)[.]{1}(\d*)', line)	#get ip info: "10.0.2.10:1108 to 10.0.2.1:38181"
				if trafficInfo:
					#print(trafficInfo.group())
					parseTrafficInfo(trafficInfo.group())	#parse out ip info and add numPackets to packet counts
				now = time.time()
				#print("now is %d" % now)
				print(now - start)
				if int(now - start) >= loopTime:	#if the set time interval has passed, push the current traffic stat data and reset packet counters
					pushTrafficStats()
					resetTeamStats()
					start = time.time()
		else:
			numPackets = 0	#reset numPackets to 0 if it was not found, just to be safe

numPackets = 0	#number of packets sent/received.  This is set in parseTrafficStats() and used in incrementPacketCount()
loopTime = 5	#how often we want to report new traffic stats, in seconds

team_info_list = createTeamInfoList(config_file)		#first parse the config and get the team info (name & subnet)
team_stats_list = createTeamStatsList(team_info_list)	#use the team info to create the stats_list (incoming and outgoing)
parseTrafficStats(log_file)						#this function call gets the process going



