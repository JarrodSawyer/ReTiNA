#!/usr/bin/env python2.6

#Usage: python AttackStats.py teams.cfg logfile.txt
#
#AttackStats takes in two arguments, a teams config file and a Snort log file
#We parse out the team info from the config, giving us a list of team names and subnets
#We then begin parsing the log file line by line, collecting attack info such as source & destination ip's and type of attack
#Each new attack and its info is written to the database using a wrapper

import sys
import time
import re
sys.path.append("../database")
import DatabaseWrapper
import config

#check for correct number of arguments
if len(sys.argv) != 2:
	print("usage: python AttackStats.py teams.cfg")
	exit();

#check for valid teams config
try:
	#check if the file exists by opening it
	config_file = open(sys.argv[1], 'r')
except IOError:
	#failed to open file
	print('Could not open file: %s' % sys.argv[1])
	exit();


#creates a list by parsing a config file, each item of which is a tuple containing team_name and subnet.
#so it will look something like this: [ (white, 10.0.0) , (red, 10.0.1) , (blue, 10.0.2) ]
def createTeamInfoList(config_file):
	
	team_info = []	#list containing team names and subnets
	while 1:
		line = config_file.readline()
		if not line:
			break
		pass 
		space_index = line.find(" ")					#name and subnet are space seperated
		team_name = line[ :space_index ]				#get everything up to space
		team_subnet = line[ space_index+1: ]			#get everything after space
		team_subnet = team_subnet.replace('\n', "")	#remove any newline characters
		team_info.append( (team_name, team_subnet) )	#stores a tuple, ie. (white, 10.0.1)
	return team_info;

#returns the team name that is associated with the given subnet
def getTeamBySubnet(subnet):
	
	global team_info			#make global team_info list locally available
	for item in team_info:
		if item[1] == subnet:	#each list element is a tuple.  First tuple element is team_name, second is team_subnet
			return item[0]
	return -1

#parses out the relevant data from each line of the snort log.
#the input string should look something like this: "10.0.0.110:48331 -> 10.0.2.11:80"
def parseAttackInfo(ip_to_ip):
	
	attack_info = []	#list containing attacker ip, attacker team name, receiver ip, receiver team name
	if ip_to_ip != "":
		space_index = ip_to_ip.find(" ")			#find the first space
		
		attacker_ip = ip_to_ip[ :space_index ]			#substring out acttacker ip: "10.0.0.110" (and possibly a port)
		attacker_ip = attacker_ip[ :attacker_ip.find(":") ]	#substring off the port if there is one
		receiver_ip = ip_to_ip[ (space_index+4): ]		#substring out receiver ip: "10.0.2.11" (and possibly a port)
		receiver_ip = receiver_ip[ :receiver_ip.find(":") ]
		#print("attacker ip: %s"  % attacker_ip);
		#print("receiver ip: %s"  % receiver_ip);
		attacker_subnet = attacker_ip[ :attacker_ip.rfind(".") ]		#substring relevant subnet info: "10.0.2"
		receiver_subnet = receiver_ip[ :receiver_ip.rfind(".") ]
		#print("attacker subnet: %s"  % attacker_subnet);
		#print("receiver subnet: %s"  % receiver_subnet);
		attacker_team = getTeamBySubnet(attacker_subnet)		#get the team name associated with the given subnet
		receiver_team = getTeamBySubnet(receiver_subnet)
		#print("attacker team: %s"  % attacker_team);
		#print("receiver team: %s"  % receiver_team);
		if attacker_ip != "" and receiver_ip != "":
			if attacker_team != -1 and receiver_team != -1:
				attack_info.append( (attacker_ip, attacker_team) )
				attack_info.append( (receiver_ip, receiver_team) )
			else:
				#print("error getting team name by subnet")
				#print(ip_to_ip)
				return -1
		else:
			#print("error getting attacker/receiver ip's")
			#print(ip_to_ip)
			return -1
	else:
		return -1
	return attack_info	#successfully parsed attack info

#use the database wrapper to send new attack info.
#sent data includes the 
def addNewAttackEntry(attackInfo, attackType, attackTime, dbwrapper):
	
	#print("pushing new attack entry to database")
	now = time.time()
	timetodie = now+10	#what the hell is this for anyway?  Included because it was in the original perl script
	attacker_ip = attackInfo[0][0]
	attacker_team = attackInfo[0][1]
	receiver_ip = attackInfo[1][0]
	receiver_team = attackInfo[1][1]
	#print("attacker ip: %s" % attacker_ip)
	#print("attacker team: %s" % attacker_team)
	#print("receiver ip: %s" % receiver_ip)
	#print("attacker team: %s" % receiver_team)
	#print("attack type: %s" % attackType)
	#print("attack time: %s" % attackTime)
	
	dbwrapper.addAttack(attacker_ip, attacker_team, receiver_ip, receiver_team, attackType, attackTime, timetodie, now)

def initiateDBConnection():
	dbinfo = config.database
	dbwrapper = DatabaseWrapper.dbconnect(dbinfo['host'])
	dbwrapper.login(dbinfo['user'], dbinfo['password'],dbinfo['db'])
	return dbwrapper

#parses the given snort log line and determines attack type based on keywords.  Returns "Unknown" if no keywords are found
def parseAttackType(line):
	
	attackType = re.search( 'Nessus', line)
	if attackType:
		return "Nessus"
	attackType = re.search( 'POLICY', line)
	if attackType:
		ssh_attack = re.search( 'POLICY SSH', line)
		if ssh_attack:
			return "SSH Login Attempt"
		ftp_attack = re.search( 'POLICY FTP', line)
		if ftp_attack:
			return "FTP Login Attempt"
		mysql_attack = re.search( 'POLICY MYSQL', line)
		if mysql_attack:
			return "MYSQL Login Attempt"
		else:
			return "Policy violation"
	attackType = re.search( 'TCP_PORTSCAN', line)
	if attackType:
		return "TCP Portscan"
	attackType = re.search( 'UDP_PORTSCAN', line)
	if attackType:
		return "UDP Portscan"
	attackType = re.search( 'SYN_PORTSCAN', line)
	if attackType:
		return "SYN Portscan"
	attackType = re.search( 'SHELLCODE', line)
	if attackType:
		noop_attack = re.search( 'SHELLCODE x86 inc ebx NOOP', line)
		if noop_attack:
			return "NOOP operation"
		else:
			return "SHELLCODE attempt"
	attackType = re.search( 'DDOS', line)
	if attackType:
		ping_flood = re.search( 'Trin00', line)
		if ping_flood:
			return "DDOS ping flood"
		else:
			return "DDOS"
	attackType = re.search( 'DOS', line)
	if attackType:
		return "Denial of Service"
	attackType = re.search( 'EXPLOIT', line)
	if attackType:
		return "Exploit attempt"
	attackType = re.search( 'FINGER', line)
	if attackType:
		return "Finger exploit attempt"
	attackType = re.search( 'FTP', line)
	if attackType:
		return "Illegal FTP use"
	attackType = re.search( 'ICMP', line)
	if attackType:
		return "Bad ICMP traffic"
	attackType = re.search( 'MISC', line)
	if attackType:
		return "Miscellaneous"
	attackType = re.search( 'MYSQL', line)
	if attackType:
		return "MYSQL usage attempted"
	attackType = re.search( 'PORN', line)
	if attackType:
		return "Someone's dirty"
	attackType = re.search( 'RPC', line)
	if attackType:
		return "RPC illegal usage"
	attackType = re.search( 'SCAN', line)
	if attackType:
		return "A scan of something"
	attackType = re.search( 'TELNET', line)
	if attackType:
		return "Illegal TELNET use"
	attackType = re.search( 'TFTP', line)
	if attackType:
		return "TFTP bad traffic"
	attackType = re.search( 'X11', line)
	if attackType:
		return "X11 hack attempt"
	attackType = re.search( 'ATTACK-RESPONSES', line)
	if attackType:
		return "Machine has been compromised"
	attackType = re.search( 'BACKDOOR', line)
	if attackType:
		return "Backdoor attack attempt"
	attackType = re.search( 'BOTNET-CNC', line)
	if attackType:
		return "Botnet dacryptic activity"
	attackType = re.search( 'CHAT', line)
	if attackType:
		return "Chat program in use"
	attackType = re.search( 'DNS', line)
	if attackType:
		return "DNS attack"
	attackType = re.search( 'IMAP', line)
	if attackType:
		return "IMAP server attack"
	attackType = re.search( 'MULTIMEDIA', line)
	if attackType:
		return "Multimedia program in use"
	attackType = re.search( 'NETBIOS', line)
	if attackType:
		return "NetBIOS attack"
	attackType = re.search( 'NNTP', line)
	if attackType:
		return "NNTP vulnerability exploit"
	attackType = re.search( 'ORACLE', line)
	if attackType:
		return "Oracle exploit"
	attackType = re.search( 'P2P', line)
	if attackType:
		return "Peer to peer traffic"
	attackType = re.search( 'PHISHING-SPAM', line)
	if attackType:
		return "Spam email attack"
	attackType = re.search( 'POP3', line)
	if attackType:
		return "POP3 server attack"
	attackType = re.search( 'RSERVICES', line)
	if attackType:
		return "Remote login, shell, or exec exploit"
	attackType = re.search( 'SCADA', line)
	if attackType:
		return "SCADA exploit"
	attackType = re.search( 'SMTP', line)
	if attackType:
		return "SMTP server attack"
	attackType = re.search( 'SNMP', line)
	if attackType:
		return "SNMP connection made"
	attackType = re.search( 'SPYWARE-PUT', line)
	if attackType:
		return "Spyware"
	attackType = re.search( 'SQL', line)
	if attackType:
		return "SQL exploit"
	attackType = re.search( 'VOIP-SIP', line)
	if attackType:
		return "VIOP exploit"
	attackType = re.search( 'WEB-ACTIVEX', line)
	if attackType:
		return "ActiveX exploit"
	attackType = re.search( 'WEB-CGI', line)
	if attackType:
		return "CGI exploit"
	attackType = re.search( 'WEB-CLIENT', line)
	if attackType:
		return "Attack against web user"
	attackType = re.search( 'WEB-COLDFUSION', line)
	if attackType:
		return "ColdFusion exploit"
	attackType = re.search( 'WEB-FRONTPAGE', line)
	if attackType:
		return "Frontpage exploit"
	attackType = re.search( 'WEB-IIS', line)
	if attackType:
		return "Microsoft web server attack"
	attackType = re.search( 'WEB-MISC', line)
	if attackType:
		return "Miscellaneous web exploit"
	attackType = re.search( 'WEB-PHP', line)
	if attackType:
		return "PHP exploit"
	attackType = re.search( 'PSNG_TCP_PORTSWEEP', line)
	if attackType:
		return "TCP portsweep"
	attackType = re.search( 'NON-RFC DEFINED CHAR', line)
	if attackType:
		return "Pre-processor detects malicious network traffic"
	attackType = re.search( 'OVERSIZE REQUEST-URI DIRECTORY', line)
	if attackType:
		return "Oversized request"
	else:
		return "Unknown"

#main script loop, which reads the snort log one line at a time and finds new attack entries
#if all required info for the attack is found, parseAttackInfo() is called.
def parseAttackLog():
	
	dbwrapper = initiateDBConnection()
	while 1:
		line = sys.stdin.readline()
		if not line:
			print("Reached end of log file")
			exit();
		pass
		attackTimeEntry = re.search('(\d+\/\d+-\d+:\d+:\d+.\d+)', line)
		if attackTimeEntry:
			attackTime = attackTimeEntry.group()
			#print(attackTimeEntry.group())
			attackIPs = re.search('(\d*)[.]{1}(\d*)[.]{1}(\d*)[.]{1}(\d*)[:]*(\d*) -> (\d*)[.]{1}(\d*)[.]{1}(\d*)[.]{1}(\d*)', line)	#get ip info: "10.0.2.10:1108 to 10.0.2.1:38181"
			if attackIPs:
				#print(attackIPs.group())
				attackInfo = parseAttackInfo(attackIPs.group())	#returns list containing attacker ip, attacker team, receiver ip, receiver team
				if attackInfo != -1:
					attackType = parseAttackType(line)
					if attackInfo != -1:
						if attackType != "":
							addNewAttackEntry(attackInfo, attackType, attackTime, dbwrapper)
	dbwrapper.close()
				#else:
					#print("Foreign subnet detected: ignoring log entry.")

team_info = createTeamInfoList(config_file)		#first parse the config and get the team info (name & subnet)
parseAttackLog()					#this function call gets the process going



