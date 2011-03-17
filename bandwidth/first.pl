#!/usr/local/bin/perl

@logfile =  <STDIN>;
chomp (@logfile);

my %game = ();

foreach $line (@logfile)
{
 
 if ($line =~ m/(\d*) bytes/) {
  $data = $1;
 }

 if ($line =~ m/(\d*)[.]{1}(\d*)[.]{1}(\d*)[.]{1}(\d*)[:]*(\d*) to (\d*)[.]{1}(\d*)[.]{1}(\d*)[.]{1}(\d*)/) {
  $a2a = ("$1$2$3$6$7$8");
 }

 if( exists $game {$a2a}) {
#	print "$game{$a2a}";
#	print "\n$data\n";
	$game{$a2a} = ($game{$a2a}+$data);
 }
 else {
	$game{$a2a} = $data;
 } 

}

for my $key ( keys %game ) {
        my $value = $game{$key};
	if($key =~ m/10.0.0\d+/){
	 $whiteTotal = $whiteTotal + $value;
	}
    }
my $r2b = $game{10011002};
my $b2r = $game{10021001};
my $r2w = $game{10011000};
my $b2w = $game{10021000};

if(!defined($whiteTotal))
{
	$whiteTotal = 0;
}
if(!defined($r2b))
{
	$r2b = 0;
}
if(!defined($b2r))
{
	$b2r = 0;
}
if(!defined($r2w))
{
	$r2w = 0;
}
if(!defined($b2w))
{
	$b2w = 0;
}

print "White = $whiteTotal\nR2B = $r2b\nB2R = $b2r\nR2W = $r2w\nB2W = $b2w\n\n";


