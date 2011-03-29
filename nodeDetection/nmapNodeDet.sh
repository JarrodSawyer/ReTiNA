#!/bin/bash
#nmap based active node detection featuring OS detection 
#and limited port scanning.  Designed to be used with the
#Cyberstorm Network Visualization system.
#See the nodes.conf file to customize teams, IP addresses and ports
#
#   By: Michael King
#   2010
#############################################################################

debug=0
SCAN="nmap -O --fuzzy --max-os-tries=1"
config=./nodes.conf
logfile=./log/nodeLog.log
if [ -a "$logfile" ]; then
    suf=`date +%s`
    mv "$logfile" "$logfile.$suf"
fi
source $config

scanPorts=`echo ${PORTS[@]} | tr ' ' ','`
for tname in ${TEAMS[@]}
do
    team="$tname"
    #get variables holding ip information
    eval sub=\$"${team}_SUB"
    eval scanIPs=\$"{${team}_SCAN_IPS[@]}"
    eval noScanIPs=\$"{${team}_NO_SCAN_IPS[@]}"
    eval ntypeArr=( \$"{${team}_NTYPES[@]}" )

echo "ntypeArr: ${ntypeArr[@]}"
echo "ntA[1]: ${ntypeArr[1]}"
if [ $debug -eq 0 ]; then
    echo "scanIPS= ${scanIPs[@]}"
    echo "noscan= ${noScanIPs[@]}"
fi	

    scanPrefs=() 
    
    #compile IPs to be scanned
    for ip in ${scanIPs[@]}
    do
	scanPrefs=( "${scanPrefs[@]}" "$sub$ip" )
    done
    
    noScanPrefs=()

    for ip in ${noScanIPs[@]}
    do
	noScanPrefs=( "${noScanPrefs[@]}" "$sub$ip" )
    done
    
    #Get all IPs on subnet
    iplist=`nmap -n -sP "$sub.2-254" | grep "Nmap scan report" | cut -d' ' -f5`    
    fullList=( "${scanPrefs[@]}" "${noScanPrefs[@]}" "${iplist[@]}" )     

    #Combine config IPs with nmap scan IPs and remove duplicates
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
        #delete cache since new one will be written after OS detection
        rm "$cache"
    fi
	if [ $debug -eq 0 ]; then
		echo "CacheArr: ${cacheArr[@]}"
		echo ""
	fi
    #remove cached IPs no longer active
    TIME=`date +%s`
    for (( i=0; i<${#cacheArr[@]};i++ ))
    do
	cip=( ${cacheArr[i]} )
if [ $debug -eq 0 ]; then
        echo "CIP[0]: ${cip[0]}"
fi
	found=1 #false
        for ip in ${fullList[@]}
        do
	    if [[ "${cip[0]}" == "$ip" && ${cip[1]} > $TIME ]]; then
   		echo FOUND
		found=0 #true
		break
	    fi
	done
	if [ $found -eq 1 ]; then
	    cacheArr[$i]=""
	fi
    done
    #scan through IPs
    for ip in ${fullList[@]}
    do
	if [ $debug -eq 0 ]; then
	echo "IP is $ip"
	fi
	#initialize variables
	scanArr=()
	servArr=()
	ipFound="false"
	isCached="false"
	toCache="true"
	cacheIP=()
	#Check to see if IP is in the cache
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
	#checking for match in port scanned IPs
	for scanIP in ${scanPrefs[@]}
	do
	    if [ "$ip" == "$scanIP" ]; then 
		if [ $debug -eq 0 ]; then
		    echo Scanip
		fi	
		    scanArr=( `$SCAN -p$scanPorts $ip | egrep '^Running|^Too|^[0-9]{2,5}'` )
		nodeType=${ntypeArr[0]}
		ipFound="true" #I've found it!
		toCache="false" #But I don't want to cache it!
				#Time of port scans is roughly the same 
				#as the time to OS scan, not worth caching 
		break
	    fi
	done
	
	if [ "$ipFound" == "false" ]; then 
        #checking for match in non-port scanned IPs
	    for noScanIP in ${noScanPrefs[@]}
	    do
		if [ "$ip" == "$noScanIP" ]; then
		    if [[ "$isCached" == "false"  ||  $TIME -gt ${cacheIP[1]} ]]; then 
			echo "OS on non-port Scan"
			echo "isCached: $isCached"
			echo "TIME: $TIME  TTD: ${cacheIP[1]}"
			scanArr=( `$SCAN $ip | egrep '^Running|^Too'` )
			cacheIP[1]=$(($TIME+$NO_SCAN_IPS_TTD))
		     
		    fi		
		    
		    nodeType=${ntypeArr[1]}
		    ipFound="true"
		    break
		fi
	    done
	fi
	if [ "$ipFound" == "false" ]; then #if not in the pref lists
	    if [ "$prefsFound" -eq "$MAXNODE" ]; then 
		continue
	    fi
	    if [[ "$isCached" == "false" || $TIME -gt ${cacheIP[1]} ]]; then 
		echo "OS on non-pref"
		echo "TIME: $TIME"
		scanArr=( `$SCAN $ip | egrep '^Running|^Too'` )
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
		    Running* )
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
		    Too* )
			opsys="Unknown"
			break
			;;
		    No* )
			opsys="Unknown"
			break
			;;
		    ([0-9]* ) 
		        if [ $debug -eq 0 ]; then
				echo "Add services here ${scanArr[i]}"
			fi	
 		case ${scanArr[i+1]} in
			    open)
				stat=UP
				;;
			    *)
				stat=DOWN
				;;
			esac
			servArr=( "${servArr[@]}" "${scanArr[i+2]} $stat" )
			i=$i+3
			;;
		    *)
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
    #assemble and print node
	    
	node=( "$ip" "$opsys" "$team" "$nodeType" "${servArr[@]}" )

	if [ $debug -eq 0 ]; then
	    echo "NODE (Team may change if KoTH and pwnage):"
	    for item in "${node[@]}"
	    do
	        echo "   $item"
	    done
	fi
	
	
    #note that the node array format is:
    #IP
    #OS
    #TEAM
    #NODE TYPE
    #SERVICE STATUS  *optional
	
    #Write IP, OS, and Team info
	echo "IP: ${node[0]}" >> $logfile
	echo "OS: ${node[1]}" >> $logfile
	if [[ "${node[3]}" == "KoTH" ]]; then
	    tm=`curl -D - -v ftp://${node[0]}:21 2> /dev/null | grep '^220' | tee asdf | perl -nE '/(white|chuck.?norris|bruce.?lee)/i && print "$1\n"'`
	    if [ "$tm" == "Chuck Norris" ]; then
		    echo "Team: RED" >> $logfile
	    else if [ "$tm" == "Bruce Lee" ]; then
		    echo "Team: BLUE" >> $logfile
	    	else
		    echo "Team: ${node[2]}" >> $logfile
		fi
	    fi
	else
	    echo "Team: ${node[2]}" >> $logfile
	fi
	echo "NodeType: ${node[3]}" >> $logfile
	if [ ${#node[@]} -gt 4 ]; then
            for (( i=4; i<${#node[@]}; i++ ));
	    do
		echo "Service: ${node[$i]}" >> $logfile
	    done
	else
		echo "Service: none" >> $logfile
	fi
	echo "" >> $logfile
	
    done #for ip in ${fullList[@]}
    #Write cache   
    for line in "${cacheArr[@]}"
    do
	[[ $line != "" ]] && echo "$line" >> "$cache"
    done
done #for ((i in TEAM))
