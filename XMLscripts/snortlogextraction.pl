#!/usr/bin/perl

$| = 1;
use CGI qw(:standard);
use File::Tail;

  $file=File::Tail->new(name=>"/home/cyberstorm/cyberstorm/realtime-backend/XMLscripts/alert.fast", maxinterval=>0.1, adjustafter=>0.1);
  
  while (defined($line=$file->read)) {
    if($line =~ /(\d+\/\d+-\d+:\d+:\d+.\d+)/){
	$timestamp = $&;
	print "timestamp = $timestamp\n";
	$timetodie = time()+10;
	print "timetodie = $timetodie\n";
    }
    if($line =~ /(seq \d*)/){
	$seqnum = substr($&,4);
	print "sequence number = $seqnum\n";
    }
    if($line =~ /(} \d+)(\.\d+){3}/){
	$source = substr($&, 2);
        print "sourceip = $source\n";
    }
    if($line =~ /(IP \d+)(\.\d+){4}/){
	@srcip = split (/\./,$&);
	$srcport = $srcip[4];
	print "source port = $srcport\n";
    }
    if($line =~ /(> \d+)(\.\d+){3}/){
        $dest = substr($&,2);
        print "destip = $dest\n";
    }
    if($line =~ /(> \d+)(\.\d+){4}/){
	@destip = split (/\./,$&);
	$destport = $destip[4];
	print "destination port = $destport\n";
    }
    @srcip = split(/\./, $source);
    @destip = split(/\./, $dest);

    if($destip[2] =~ 0){
	print "destTeam = white\n";
    }
    elsif($destip[2] == 1){
	print "destTeam = red\n";
    }
    elsif($destip[2] == 2){
	print "destTeam = blue\n";
    }

    if($srcip[2] == 0){
	print "teamname = white\n";
	print STDERR "$srcip[2]";
    }
    elsif($srcip[2] == 1){
	print "teamname = red\n";
    }
    elsif($srcip[2] == 2){
	print "teamname = blue\n";
    }

    if($line =~ /(Nessus)/){
	print "attacktype = nessus\n\n";
    }
    elsif($line =~ /(POLICY)/){
    	if($line =~ /(POLICY SSH)/){
		print "attacktype = SSH Login Attempt\n\n";
	}
	elsif($line =~ /(POLICY FTP)/){
		print "attacktype = FTP Login Attempt\n\n";
   	 }	
	 elsif($line =~ /(POLICY MYSQL)/){
		print "attacktype = MYSQL Login Attempt\n\n";
	 }
	else{
		print "attacktype = Policy violation\n\n";
	}
    }
    elsif($line =~ /(TCP_PORTSCAN)/){
	print "attacktype = TCP Portscan\n\n";
    }
    	elsif($line =~ /(UDP_PORTSCAN)/){
		print "attacktype = UDP Portscan\n\n";
    }
    elsif($line =~ /(SYN_PORTSCAN)/){
	print "attacktype = SYN Portscan\n\n";
    }
    elsif($line =~ /(SHELLCODE)/){
	
    	if($line =~ /(SHELLCODE x86 inc ebx NOOP)/){
		print "attacktype = NOOP operation\n\n";
    	}
	else{
		print "attacktype = SHELLCODE attempt\n\n";
	}
    }
    elsif($line =~ /(DDOS)/){
    	if($line =~ /(Trin00)/){
		print "attacktype = DDOS ping flood\n\n"
    	}
	else{
		print "attacktype = DDOS\n\n";
	}
    }	
    elsif($line =~ /(DOS)/){
	print "attacktype = Denial of Service\n\n";
    }
    elsif($line =~ /(EXPLOIT)/){
	print "attacktype = Exploit attempt\n\n";
    }
    elsif($line =~ /(FINGER)/){
    	print "attacktype = Finger exploit attempt\n\n";
    }
    elsif($line =~/(FTP)/){
	print "attacktype = illegal FTP use\n\n";
    }
    elsif($line =~/(ICMP)/){
	print "attacktype = bad ICMP traffic\n\n";
    }   
    elsif($line =~/(MISC)/){
	print "attacktype = miscellaneous\n\n";
    }   
    elsif($line =~/(MYSQL)/){
	print "attacktype = MYSQL usage attempted\n\n";
    }   
    elsif($line =~/(PORN)/){
	print "attacktype = someone's dirty\n\n";
    }
    elsif($line =~ /(RPC)/){
	print "attacktype = RPC illegal usage\n\n"
    }    
    elsif($line =~ /(SCAN)/){
	print "attacktype = A scan of something\n\n"
    }    
    elsif($line =~ /(TELNET)/){
	print "attacktype = Illegal TELNET use\n\n"
    }    
    elsif($line =~ /(TFTP)/){
	print "attacktype = TFTP bad traffic\n\n"
    }    
    elsif($line =~ /(X11)/){
	print "attacktype = X11 hack attempt\n\n"
    }    
    else{
	print "attacktype = unknown\n\n";
    }
    $i++;
}
