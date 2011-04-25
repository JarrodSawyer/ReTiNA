Traffic Statistics Gathering 
Ryan Rollins

-------------------------------------------------------------------------------------------------------------------------------------------
SPECIFICATIONS
-------------------------------------------------------------------------------------------------------------------------------------------
This module uses the IPTraf program to generate statistics on network traffic between three
specified subnets.  These subnets are hard-coded so modifying them requires changing the source
for this module



-------------------------------------------------------------------------------------------------------------------------------------------
REQUIRED
-------------------------------------------------------------------------------------------------------------------------------------------
The necessary components for installation on a  Linux system:
IpTraf - To install just type "sudo apt-get install iptraf"
Perl compiler - Comes standard on most if not all distos of Linux, else "sudo apt-get install perl"
Python compiler - To install just type "sudo apt-get install python"



-------------------------------------------------------------------------------------------------------------------------------------------
HOW TO
-------------------------------------------------------------------------------------------------------------------------------------------
First, navigate the terminal to the directory of the files
Second, run the script called "doit" by typing "./doit"
Everything then takes care of itself.

All should go as planned and the traffic statistics should be uploaded to the database.