#!/bin/bash
#Nmap based active node detection featuring OS detection 
#and limited port scanning.  Designed to be used with the
#Cyber Storm Network Visualization system.
#See the nodes.conf file to customize teams, IP addresses and ports
#
#   By: Michael King
#   2010
#
#   Updated by: Jarrod Sawyer
#   Date: 4/20/2011
#############################################################################

debug=0
SCAN="nmap -O --fuzzy --max-os-tries=1"
config=./nodes.conf
logfile=./log/nodeLog.log

# If a logfile already exists save it and add the date/time to the file name
if [ -a "$logfile" ]; then 
    suf=`date +%s`
    mv "$logfile" "$logfile.$suf"
fi
source $config

# Get KOTH boxes from XSCORE

kothBoxes="10.0.0.15 White:10.0.0.3 Red:10.0.0.100 Blue:10.0.0.78 White" # Need to call XSCORE CGI script here

# Splits the string from XScore at the colons
ipOwner=($(echo $kothBoxes | sed -e 's/'":"'/\n/g' | while read line; do echo $line | sed 's/[\t ]/'":"'/g'; done))

# Replaces the colons with spaces
for (( i = 0; i < ${#ipOwner[@]}; i++ )); do
  ipOwner[i]=$(echo ${ipOwner[i]} | sed 's/'":"'/ /')
done

declare -A ipOwnerMap # Holds the IP of the KOTH box and its corresponding owner

i=0

# Goes through all of the IP/owner pairs and builds a list of the IPs and the map of the two
while [  $i -lt ${#ipOwner[@]} ]
do
    owner=`echo ${ipOwner[$i]} | cut -d' ' -f2` # Owner                                                                                                                               
    ip=`echo ${ipOwner[$i]} | cut -d' ' -f1` # IP                                                                                                                                             
 
    ipOwnerMap[$ip]=$owner
    ip=`echo ${ip} | cut -d'.' -f4` # Gets the last octet of the IP address. So if it is 10.0.0.69 gets 69.
    ip=".$ip" # Makes it .69
    
    ipList[$i]=$ip 
    let i=$i+1
done

scanPorts=`echo ${PORTS[@]} | tr ' ' ','` # Ports to scan
for tname in ${TEAMS[@]} # Main Loop
do
    team="$tname"
    # Get variables holding ip information
    eval sub=\$"${team}_SUB"
    eval scanIPs=\$"{${team}_SCAN_IPS[@]}"

    if [ "$team" == "WHITE" ] # The NO_SCAN_IPS list is treated as KOTH boxes for white team so add the
    then                       # KOTH box ips gotten from XSCORE to the list if the team is white
	eval noScanIPs=( \${${team}_NO_SCAN_IPS[@]} ${ipList[@]} )
    else
	eval noScanIPs=\$"{${team}_NO_SCAN_IPS[@]}"
    fi

    eval ntypeArr=( \$"{${team}_NTYPES[@]}" )

echo "ntypeArr: ${ntypeArr[@]}"
echo "ntA[1]: ${ntypeArr[1]}"
if [ $debug -eq 0 ]; then
    echo "scanIPS= ${scanIPs[@]}"
    echo "noscan= ${noScanIPs[@]}"
fi	

    scanPrefs=() 
    
    # Compile IPs to be scanned
    for ip in ${scanIPs[@]}
    do
	scanPrefs=( "${scanPrefs[@]}" "$sub$ip" )
    done
    
    noScanPrefs=()

    for ip in ${noScanIPs[@]}
    do
	noScanPrefs=( "${noScanPrefs[@]}" "$sub$ip" )
    done
    
    # Get all IPs on subnet
    echo $sub
    iplist=`nmap -n -sP "$sub.2-254" | grep "Nmap scan report" | cut -d' ' -f5`    
    fullList=( "${scanPrefs[@]}" "${noScanPrefs[@]}" "${iplist[@]}" )     

    # Combine config IPs with nmap scan IPs and remove duplicates
    fullList=( `echo "${fullList[@]}" | tr " " "\n" | sort -u` )

if [ $debug -eq 0 ];then
    echo "fullList= ${fullList[@]}"
fi
    
    prefsFound=0
    
    #Load ips from cache file
    index=0
    cache="$team.cache"
    cacheArr=()

    if [ -a $cache ];  then	    
        while read line
        do
	    cacheArr[index]="$line"
	    let index++
        done < "$cache"
        # Delete cache since new one will be written after OS detection
        rm "$cache"
    fi
	if [ $debug -eq 0 ]; then
		echo "CacheArr: ${cacheArr[@]}"
		echo ""
	fi
    # Remove cached IPs no longer active
    TIME=`date +%s`
    for (( i=0; i<${#cacheArr[@]};i++ ))
    do
	cip=( ${cacheArr[i]} )
if [ $debug -eq 0 ]; then
        echo "CIP[0]: ${cip[0]}"
fi
	found=1 # False
        for ip in ${fullList[@]}
        do
	    if [[ "${cip[0]}" == "$ip" && ${cip[1]} > $TIME ]]; then
   		echo FOUND
		found=0 # True
		break
	    fi
	done
	if [ $found -eq 1 ]; then
	    cacheArr[$i]=""
	fi
    done
    # Go through list of found IPs
    for ip in ${fullList[@]}
    do
	if [ $debug -eq 0 ]; then
	echo "IP is $ip"
	fi
	# Initialize variables
	scanArr=()
	servArr=()
	ipFound="false"
	isCached="false"
	toCache="true"
	cacheIP=()
	# Check to see if IP is in the cache
	for (( i=0; i<${#cacheArr[@]}; i++ ))
	do
	    #NOTE: cacheIP format is ( IP TimeToDie OS )
	    cacheIP=( ${cacheArr[i]} )
	    if [ "${cacheIP[0]}" == "$ip" ]; then
		isCached="true"
		echo isCached
		break
	    fi
	done
echo "ISCACHE: $isCached"
	# Checking for match in port scanned IPs
	for scanIP in ${scanPrefs[@]}
	do
	    if [ "$ip" == "$scanIP" ]; then 
		if [ $debug -eq 0 ]; then
		    echo Scanip
		fi	
		scanArr=( `$SCAN -p$scanPorts $ip | egrep '^Running|^Too|^[0-9]{2,5}'` ) # Scans for IPs designated in conf file 
		nodeType=${ntypeArr[0]}                                                # as IPs to scan ports on
 		ipFound="true" # I've found it!
		toCache="false" # But I don't want to cache it!
				# Time of port scans is roughly the same 
				# as the time to OS scan, not worth caching 
		break
	    fi
	done
	
	if [ "$ipFound" == "false" ]; then 
        # Checking for match in non-port scanned IPs
	    for noScanIP in ${noScanPrefs[@]}
	    do
		if [ "$ip" == "$noScanIP" ]; then
		    if [[ "$isCached" == "false"  ||  $TIME -gt ${cacheIP[1]} ]]; then 
			echo "OS on non-port Scan"
			echo "isCached: $isCached"
			echo "TIME: $TIME  TTD: ${cacheIP[1]}"
			scanArr=( `$SCAN $ip | egrep '^Running|^Too'` ) # In depth scan for IPs not on the port scan list
			cacheIP[1]=$(($TIME+$NO_SCAN_IPS_TTD))
		     
		    fi		
		    
		    nodeType=${ntypeArr[1]}
		    ipFound="true"
		    break
		fi
	    done
	fi
	if [ "$ipFound" == "false" ]; then # If not in the pref lists
	    if [ "$prefsFound" -eq "$MAXNODE" ]; then 
		continue
	    fi
	    if [[ "$isCached" == "false" || $TIME -gt ${cacheIP[1]} ]]; then 
		echo "OS on non-pref"
		echo "TIME: $TIME"
		scanArr=( `$SCAN $ip | egrep '^Running|^Too'` ) # In depth scan for IPs not on a preference list
		cacheIP[1]=$(($TIME+$CACHE_TTD))
	    fi		
	    
	    nodeType=${ntypeArr[2]}
	fi
	
	
	if [ "${#scanArr[@]}" -eq 0 ]; then
	    opsys="DOWN"
	else
#	    if [ $toScan == "true" ]; then
#	    fi
		len=${#scanArr[@]}
		echo ${scanArr[@]}
	    for (( i=0; i<len; ))
	    do
		case ${scanArr[$i]} in
		    Running* ) # Determining Operating System
			echo "Running input: ${scanArr[*]:i+1:$len-i+1}"
			len=${#scanArr[@]}
			opsys="${scanArr[@]:i+1:$len-i+1}"
			tmp=( $opsys )
			if [ "${tmp[0]}" == "(JUST" ]; then
				opsys=`echo $opsys | cut -d: -f2 | cut -d\( -f 1`
			fi
			opsys=`echo "$opsys" | tr ' ' '_'`
			echo "Opsys: $opsys"
			break
			;;
		    Too* ) # Unknown OS
			opsys="Unknown"
			break
			;;
		    No* ) # Unknown OS
			opsys="Unknown"
			break
			;;
		    ([0-9]* ) 
		        if [ $debug -eq 0 ]; then
				echo "Add services here ${scanArr[i]}"
			fi	
 		case ${scanArr[i+1]} in
			    open) # Services
				stat=UP
				;;
			    *) # Services
				stat=DOWN
				;;
			esac
			servArr=( "${servArr[@]}" "${scanArr[i+2]} $stat" )
			i=$i+3
			;;
		    *) # Everything else
			echo Default??
			echo "${scanArr[i]}"
			let i++
		esac		
	    done
	fi
	if [ "$isCached" == "true" ]; then
		echo "CACHE: ${cacheIP[@]}"
		echo "CACHE[2]: ${cacheIP[2]}"	
	len=${#cacheIP[@]}
	    opsys=${cacheIP[@]:2:$len-1}
		echo "OPSYS: $opsys"
	elif [ "$opsys" != "DOWN" -a "$toCache" != "false" ]; then
echo "Not cached $ip" 
		cacheIP[0]="$ip"
	    cacheIP[2]="$opsys"
	    cacheArr[${#cacheArr[@]}]="${cacheIP[@]}"
	fi
    # Assemble and print node to log file
	    
	node=( "$ip" "$opsys" "$team" "$nodeType" "${servArr[@]}" )

	if [ $debug -eq 0 ]; then
	    echo "NODE (Team may change if KoTH and pwnage):"
	    for item in "${node[@]}"
	    do
	        echo "   $item"
	    done
	fi
	
	
    # Note that the node array format is:
    # IP
    # OS
    # TEAM
    # NODE TYPE
    # SERVICE STATUS  *optional
	
    # Write IP, OS, and Team info
	echo "IP: ${node[0]}" >> $logfile
	echo "OS: ${node[1]}" >> $logfile
	if [[ "${node[3]}" == "KoTH" ]]; then
	    #tm=`curl -D - -v ftp://${node[0]}:21 2> /dev/null | grep '^220' | tee asdf | egrep -w -i -o "$team_string"`
	    #tm=`echo $tm | tr [A-Z] [a-z]`                                  BACKUP CALLS IF XSCORE CALL DOES NOT WORK
	    echo "Team: ${ipOwnerMap[${node[0]}]}" >> $logfile # Get the owner of the current KOTH box
	    
	else
	    echo "Team: ${node[2]}" >> $logfile  # If not KOTH base owner on IP address
	fi
	echo "NodeType: ${node[3]}" >> $logfile
	if [ ${#node[@]} -gt 4 ]; then
            for (( i=4; i<${#node[@]}; i++ )); # Print services
	    do
		echo "Service: ${node[$i]}" >> $logfile
	    done
	else
		echo "Service: none" >> $logfile
	fi
	echo "" >> $logfile
	
    done # For ip in ${fullList[@]}
    # Write found nodes to cache   
    for line in "${cacheArr[@]}"
    do
	[[ $line != "" ]] && echo "$line" >> "$cache"
    done
done #for ((i in TEAM)) Main Loop End
