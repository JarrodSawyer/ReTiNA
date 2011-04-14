#!/bin/bash
configfile='nodes.conf'
configfile_secured='snodes.conf'
logfile="nodeLog.log"
redcount=0
whitecount=0
bluecount=0

# check if the file contains something we don't want
if egrep -q -v '^#|^[^ ]*=[^;]*' "$configfile"; then
  echo "Config file is unclean, cleaning it..." >&2
  # filter the original to a new file
  egrep '^#|^[^ ]*=[^;&]*'  "$configfile" > "$configfile_secured"
  configfile="$configfile_secured"
fi
source $configfile
echo E1
echo '' > $logfile
dump_array () {
    #note that the passed array format is:
    #IP
    #OS
    #TEAM
    #SERVICE STATUS  *optional
    array=( "$@" )
    if [ ${#array[@]} == 0 ]; then
	echo "Error in dump_array: No array passed!"
	return 0
    fi
    
    if [ ${#array[@]} -lt 3 ]; then
	echo "Error in dump_array: passed array to short!"
	echo "Needs at least IP, OS, TEAM"
	echo "${array[@]}"
	return 0
    fi
    
    #Write IP, OS, and Team info
    echo "IP: ${array[0]}" >> $logfile
    echo "OS: ${array[1]}" >> $logfile
    echo "Team: ${array[2]}" >> $logfile

    if [ ${#array[@]} -gt 3 ]; then
        for (( i=3; i<=${#array[@]}; i++ ));
	do
	    echo "Service: ${array[$i]}" >> $logfile
	done
    fi
    
}
echo E2
pref_node_scan () {
#performs the scan for the nodes using port scanning
#expects an array of IP addresses
    iparray=( "$@" ) #set iparray to the array passed.
                     #the array is split, $1=array[0] $2=array[1] ...
    
    if [ ${#iparray} == 0 ]; then
	echo "Error in pref_node_scan: exactly 1 array argument expected"
	echo
	return 0
    fi
    
    #use nmap to check ports from $PORTS in configfile
    
    ports=$(echo ${PORTS[@]} | tr ' ' '|')
 #   echo "Ports: $ports"
    for ip in ${iparray[@]}
    do
	case $ip in
	    $RED_SUB*)
		team="RED"
		;;
	    $BLUE_SUB*)
		team="BLUE"
		;;
	    $WHITE_SUB*)
	        team="WHITE"
		;;
	esac
	node=( $ip ) 
	
	#ping to see if server is up
	rec=0
	ping -qc1 $ip > /dev/null && rec=1
	if [ "$rec" -eq "0" ]; then #no reply to ping
	    #OS=DOWN
	    node=( ${node[@]} "DOWN" )
	elif [ "$rec" -eq "1" ]; then #got a reply to the ping
	    echo Nmapping
	    scanArr=( `nmap -O $ip | egrep '$ports|^Running|^Too'` )
	    echo Nmapped
	    echo "Scan: ${scanArr[@]}"
	    declare -a servArr
	    for (( i=0; i<${#scanArr[@]}; ))
	    do
		opsys="NMAP ERROR"  ###REMOVE IN FINAL
		case ${scanArr[i]} in
		    Running*)
			echo Running
			len=${#scanArr[@]}
			opsys="${scanArr[*]:i+1:$len-i+1}"
			break    
			;;
		    Too*)
			echo Too
			opsys="Unkown"
			break
			;;
		    "[0-9]{2,5}") 
			#echo "Add services here"
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
			break
			;;
		    *)
			i=$i+1
			echo Default??
			echo "${scanArr[@]}"
		esac
	    done
	else
	    echo "Something went horribly horribly wrong pinging $ip"
	    echo "REC: $Rec"
	fi
	
	#Finally stick everything together
	node=( "${node[@]}" "$opsys" "$team" "${servArr[@]}" )
	echo "Opsys: $opsys"
	echo "Node: ${node[@]}"
	dump_array "${node[@]}"
    done
} #close the function	
echo E3
node_scan() {
    #expects 2 arguments: an array of IPs and the team associated with them
    array=( "${@:1:$#-1}" )
    team=${!#}
    if [ $# -lt 2 ]; then
	echo "Error in node_scan: expects an array of IPs and a team"
    fi
    case $team in
	RED)
	    count=$redcount
	    ;;
	BLUE)
	    count=$bluecount
	    ;;
	WHITE)
	    count=$whitecount
	    ;;
    esac
    for ip in ${array[@]}
    do
	if [ "$count" -gt "$MAX_COUNT" ]; then
	    return 0
	fi
	rec="0"
	ping -qc1 $ip > /dev/null && rec="1"
	if [ "$rec" -e "1" ];  then #something is at the IP
	    scanArr=( `nmap -O $ip | egrep '^Running|^Too'` )
	    if [ "${scanArr[0]}" -e "Running:" ]; then #OS detected
		len=${#scanArr[@]}
		opsys="${scanArr[*]:1:$len-1}"
	    else
		opsys="Unkown"
	    fi
	    node=( "$ip" "$opsys" "$team" )
	    
	    dump_array "${node[@]}"
	    count=$count+1
	else
	    `arp -d $ip`
	    
	fi
    done
	
}

declare -a riplist
declare -a biplist
declare -a wiplist
	
for i in ${RED_SCAN_IPS[*]}
do
    riplist=( ${riplist[@]} "$RED_SUB$i" )
done

for i in ${BLUE_SCAN_IPS[*]}
do
    biplist=( ${biplist[@]} "$BLUE_SUB$i" )
done
for i in ${WHITE_SCAN_IPS[*]}
do
    wiplist=( ${wiplist[@]} "$WHITE_SUB$i" )
done

echo ${riplist[@]}
echo ${biplist[@]}
echo ${biplist[1]}
echo ${wiplist}
if [ ${#riplist[@]} -ne 0 ]; then
    pref_node_scan "${riplist[@]}"
fi
dbg() {
redcount=$redcount+${#riplist[@]}
if [ ${#biplist[@]} -ne 0 ]; then
    pref_node_scan "${biplist[@]}"
fi
bluecount=$bluecount+${#biplist[@]}
if [ ${#wiplist[@]} -ne 0 ]; then
    pref_node_scan "${wiplist[@]}"
fi
whitecount=$whitecount + ${#wiplist[@]}
#grab IPS from ARP cache
activeips=( $(arp -n | cut -d" " -f1 | grep -e ^[0-9]) ) #($(...)) builds array
#dbg(){
declare -a rnoscanip
declare -a bnoscanip
declare -a wnoscanip
#Compile ips that aren't doing port scanning from the config file	
for i in ${RED_NOSCAN[*]}
do
    rnoscanip=( ${rnoscanip[@]} "$RED_SUB$i" )
done

for i in ${BLUE_NOSCAN[*]}
do
    bnoscanip=( ${bnoscanip[@]} "$BLUE_SUB$i" )
done
for i in ${WHITE_NOSCAN[*]}
do
    wnoscanip=( ${wnoscanip[@]} "$WHITE_SUB$i" )
done

#break ips into teams
tmpnewred=`echo ${activeips[*]} | grep $RED_SUB`
#add the ips from the config to the ips from arp cache
tmpnewred=( "${rnoscanip[@]}" "${tmpnewred[@]}" ) 
declare -a newred
#check ips for uniqueness (remove ips that were already scanned
#using port scanning from config file
for ip in ${tmpnewred[@]}
do
    unique="true"
    for rip in ${riplist[@]}
    do
	if [ "$rip" == "$ip" ]; then
	    unique="false"
	    echo "Match: $ip"
	    break;
	fi
    done
    if [ $unique == "true" ]; then
	newred=( "${newred[@]}" "$ip" )
    fi
done

#repeat above with next team
tmpnewblue=`echo ${activeips[*]} | grep $BLUE_SUB`
tmpnewblue=( "${bnoscanip[@]}" "${tmpnewblue[@]}" ) 
declare -a newblue
for ip in ${tmpnewblue[@]}
do
    unique="true"
    for rip in ${biplist[@]}
    do
	if [ "$rip" == "$ip" ]; then
	    unique="false"
	    echo "Match: $ip"
	    break;
	fi
    done
    if [ $unique == "true" ]; then
	newblue=( "${newblue[@]}" "$ip" )
    fi
done

tmpnewwhite=`echo ${activeips[*]} | grep $WHITE_SUB`
tmpnewwhite=( "${wnoscanip[@]}" "${tmpnewwhite[@]}" ) 
declare -a newwhite
for ip in ${tmpnewwhite[@]}
do
    unique="true"
    for rip in ${wiplist[@]}
    do
	if [ "$rip" == "$ip" ]; then
	    unique="false"
	    echo "Match: $ip"
	    break;
	fi
    done
    if [ $unique == "true" ]; then
	newwhite=( "${newwhite[@]}" "$ip" )
    fi
done

node_scan "${newred[@]}" "RED"
node_scan "${newblue[@]}" "BLUE"
node_scan "${newwhite[@]}" "WHITE"
echo Done
}
