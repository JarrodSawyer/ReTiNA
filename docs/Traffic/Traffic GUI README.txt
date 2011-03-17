############################################################
README file for Traffic GUI module of Real-Time Network 
Analysis system
Author: Delvin Jackson
Date: 1 May 2010
############################################################

Overview:

This module is run as a webpage which makes a request to "http://localhost/cgi-bin/statsreport.cgi" and visualizes the current statistics of activity on the system. As long as the statreport.cgi script is on the same webserver as the the Realtime Viz module, it should return results from the cgi script.

Unforunately, some components of the system have not been finished.  The GUI will currently only display total values for traffic.  The graphs for the real-time traffic do not work.

Installation:

The Realtime Viz module works as long as the following files are in the same directory:

realTimeViz.js - Javascript file where graphics are generated
g.raphael-min.js - Javascript library for raphael graph graphics
raphael-min.js - Javascript library for rapheal graphics
jquery-1.4.2.min.js - Javascript library for making Ajax requests
realTimeViz.html - web application page for realtime Viz


Running:

To run the Realtime Viz module, open realTimeViz.html in a web browser. The libararies are designed to run in any major web browser.
