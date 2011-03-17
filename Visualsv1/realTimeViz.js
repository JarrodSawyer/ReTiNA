var lgBlue;
var lgRed;
var lgWhite;
var total;

var time = [];
var bytes_blueToRed = [];
var bytes_blueToWhite = [];
var bytes_redToBlue = [];
var bytes_redToWhite = [];
var bytes_White = [];
//Actual coordinates below
var time_display = [];
var bytes_blueToRed_display = [];
var bytes_blueToWhite_display = [];
var bytes_redToBlue_display = [];
var bytes_redToWhite_display = [];
var bytes_White_display = [];

var counter = 0;
var timeScroll = 0;
var scrolls = 0; //Offsets the time interval
var date = new Date();
var startTime = date.getDate();
var currentTime = date.getTime();
var timeInterval = 5;

var redToBlue_Total = 0;
var blueToRed_Total = 0;
var whiteToAll_Total = 0;

window.onload = function()
{
	//Adds first values to arrays
	alert(currentTime);
	time.push(0);
	time_display.push(25);
	
	bytes_blueToRed.push(0);
	bytes_blueToRed_display.push(295);
	
	bytes_blueToWhite.push(0);
	bytes_blueToWhite_display.push(295);
	
	bytes_redToBlue.push(0);
	bytes_redToBlue_display.push(295);
	
	bytes_redToWhite.push(0);
	bytes_redToWhite_display.push(295);
	
	bytes_White.push(0);
	bytes_White_display.push(295);
	
	lgBlue = Raphael("linegraph_blue", 400, 330);
	lgRed = Raphael("linegraph_red", 400, 330);
	lgWhite = Raphael("linegraph_white", 400, 330);
	total = Raphael("totals", 600, 400);
	
	drawAxis();
	drawText();
	
	setTimeout("update();", 100); //refreshes screen ever 0.1 seconds
};

//Draws the X (Time - seconds) and Y (bytes) axis
drawAxis = function()
{
	var lines =lgBlue.path("M 25 30 L 25 295 L 330 295").attr({stroke: "white"}); 
	lines = lgRed.path("M 25 30 L 25 295 L 330 295").attr({stroke: "white"});
	lgWhite.path("M 25 30 L 25 295 L 330 295").attr({stroke: "white"});
	
	var timeBlue = lgBlue.text(350, 295, "Time");
	timeBlue.attr({font: "12px Arial", fill: "white"});
	var timeRed = lgRed.text(350, 295, "Time");
	timeRed.attr({font: "12px Arial", fill: "white"});
	var timeWhite = lgWhite.text(350, 295, "Time");
	timeWhite.attr({font: "12px Arial", fill: "white"});
	
	var bytesBlue = lgBlue.text(20, 15, "Bytes");
	bytesBlue.attr({font: "12px Arial", fill: "white"});
	var bytesRed = lgRed.text(20, 15, "Bytes");
	bytesRed.attr({font: "12px Arial", fill: "white"});
	var bytesWhite = lgWhite.text(20, 15, "Bytes");
	bytesWhite.attr({font: "12px Arial", fill: "white"});
	
	
	var x = 10;
	var xAxis = 0;
	for (var i = 0; i < 6; i++)
	{
		xAxis = Math.floor((320*x)/60) + 10;
		
		lgBlue.path("M " + xAxis + " 298 L " + xAxis + " 292").attr({stroke: "white"});
		lgBlue.text(xAxis, 285, x + timeScroll).attr({stroke: "white", font: "8px Arial"});
		
		lgRed.path("M " + xAxis + " 298 L " + xAxis + " 292").attr({stroke: "white", font: "8px Arial"});
		lgRed.text(xAxis, 285, x + timeScroll).attr({stroke: "white"});
		
		lgWhite.path("M " + xAxis + " 298 L " + xAxis + " 292").attr({stroke: "white", font: "8px Arial"});
		lgWhite.text(xAxis, 285, x + timeScroll).attr({stroke: "white"});
		
		x += 10;
	}
	
	var y = 200;
	var yAxis = 0;
	for (var i = 0; i < 5; i++)
	{
		var v = 1000 - y;
		yAxis = Math.floor((256*v)/1000) + 30;
		
		lgBlue.path("M 22 " + yAxis + " L 28 " + yAxis).attr({stroke: "white"});
		lgBlue.text(10, yAxis, y).attr({stroke: "white", font: "8px Arial"});
		
		lgRed.path("M 22 " + yAxis + " L 28 " + yAxis).attr({stroke: "white"});
		lgRed.text(10, yAxis, y).attr({stroke: "white", font: "8px Arial"});
		
		lgWhite.path("M 22 " + yAxis + " L 28 " + yAxis).attr({stroke: "white"});
		lgWhite.text(10, yAxis, y).attr({stroke: "white", font: "8px Arial"});
		
		y += 200;
	}
}

//Updates the canvas/screen
update = function()
{
	lgBlue.clear();
	lgRed.clear();
	lgWhite.clear();
	total.clear();
	
	counter++;
	if (counter == (timeInterval*10))
	{
		refreshData();
		counter = 0;		
	}
	
	drawAxis();
	drawText();
	drawData();
	drawTotal();
	
	setTimeout("update();", 100);
};

//Updates the stats - and gets the total bytes between
refreshData = function()
{
	currentTime += timeInterval;
	var blue_white;
	var blue_red;
	var red_white;
	var red_blue;
	var white;	
	
	
	$.ajax({
		type: "GET",
		url: "http://localhost/cgi-bin/StatsReport.cgi?time=" + currentTime - timeInterval,  //http://localhost/cgi-bin/StatsReport.cgi?time=12345678 & http://138.47.102.116/cgi-bin/StatsReport.cgi
		dataType: "xml",
		success: function(xml)
		{
			
			time.push(currentTime);
			$(xml).find('stat').each(function()
			{
				blue_white = parseInt($(this).attr('BluetoWhite'));
				$('#data').html("<div id='blue_white'>" + blue_white + "</div>"); 
				blue_red = parseInt($(this).attr('BluetoRed'));
				$('#data').append("<div id='blue_red'>" + blue_red + "</div>"); 
				
				red_white = parseInt($(this).attr('RedtoWhite'));
				$('#data').append("<div id='red_white'>" + red_white + "</div>"); 
				red_blue = parseInt($(this).attr('RedtoBlue'));
				$('#data').append("<div id='red_blue'>" + red_blue + "</div>"); 
				
				white = parseInt($(this).attr('White'));
				$('#data').append("<div id='white'>" + white + "</div>");
				
				redToBlue_Total += red_blue;
				blueToRed_Total += blue_red;
				whiteToAll_Total += white;
				
				bytes_blueToWhite.push(blue_white);
				bytes_blueToRed.push(blue_red);
				bytes_blueToWhite_display.push(Math.floor((256*(1000 - blue_white))/1000) + 30);
				bytes_blueToRed_display.push(Math.floor((256*(1000 - blue_red))/1000) + 30);
				
				bytes_redToWhite.push(red_white);
				bytes_redToBlue.push(red_blue);
				bytes_redToWhite_display.push(Math.floor((256*(1000 - red_white))/1000) + 30);
				bytes_redToBlue_display.push(Math.floor((256*(1000 - red_blue))/1000) + 30);
				
				bytes_White.push(white);
				bytes_White_display.push((256*(1000 - white))/1000 + 30);
				
				time.push(currentTime);
	
				if (currentTime - startTime > 60)
				{
					bytes_blueToWhite_display.reverse();
					bytes_blueToWhite_display.pop();
					bytes_blueToWhite_display.reverse();
			
					bytes_blueToRed_display.reverse();
					bytes_blueToRed_display.pop();
					bytes_blueToRed_display.reverse();
			
					bytes_redToWhite_display.reverse();
					bytes_redToWhite_display.pop();
					bytes_redToWhite_display.reverse();
			
					bytes_redToBlue_display.reverse();
					bytes_redToBlue_display.pop();
					bytes_redToBlue_display.reverse();
			
					bytes_White_display.reverse();
					bytes_White_display.pop();
					bytes_White_display.reverse();
				}
	
				else
				{
					time_display.push(Math.floor((320*currentTime)/60) + 10);	
				}
			});
		}
	});
};

//Draws line graphs statistics
drawData = function()
{	
	for (var i = 0; i < time_display.length - 1; i++)
	{
		blueToWhite = lgBlue.path("M " + time_display[i] + " " + bytes_blueToWhite_display[i] + " L " + time_display[i + 1] + " " + bytes_blueToWhite_display[i + 1]);
		blueToRed = lgBlue.path("M " + time_display[i] + " " + bytes_blueToRed_display[i] + " L " + time_display[i + 1] + " " + bytes_blueToRed_display[i + 1]);
		blueToRed.attr({stroke: "#640A0A"});
		blueToWhite.attr({stroke: "FFFFFF"});
		
		redToBlue = lgRed.path("M " + time_display[i] + " " + bytes_redToBlue_display[i] + " L " + time_display[i + 1] + " " + bytes_redToBlue_display[i + 1]);
		redToWhite = lgRed.path("M " + time_display[i] + " " + bytes_redToWhite_display[i] + " L " + time_display[i + 1] + " " + bytes_redToWhite_display[i + 1]);
		redToBlue.attr({stroke: "#10425D"});
		redToWhite.attr({stroke: "FFFFFF"});
		
		white = lgWhite.path("M " + time_display[i] + " " + bytes_White_display[i] + " L " + time_display[i + 1] + " " + bytes_White_display[i + 1]);
		white.attr({stroke: "FFFFFF"});
	}
	
	//circles
	blueToWhiteCir = lgBlue.circle(time_display[time_display.length - 1], bytes_blueToWhite_display[bytes_blueToWhite_display.length - 1], 2);
	blueToWhiteCir.attr({stroke: "none", fill: "white"});
	blueToRedCir = lgBlue.circle(time_display[time_display.length - 1], bytes_blueToRed_display[bytes_blueToRed_display.length - 1], 2);
	blueToRedCir.attr({stoke: "none", fill: "#640A0A"});
	
	redToWhiteCir = lgRed.circle(time_display[time_display.length - 1], bytes_redToWhite_display[bytes_redToWhite_display.length - 1], 2);
	redToWhiteCir.attr({stroke: "none", fill: "white"});
	redToBlueCir = lgRed.circle(time_display[time_display.length - 1], bytes_redToBlue_display[bytes_redToBlue_display.length - 1], 2);
	redToBlueCir.attr({stroke: "none", fill: "#10425D"});
	
	whiteCir = lgWhite.circle(time_display[time_display.length - 1], bytes_White_display[bytes_White_display.length - 1], 2);
	whiteCir.attr({stroke: "none", fill: "white"});
};

//Draws Screen for total bytes statistics
drawTotal = function()
{
	var title = total.text(200, 50, "Total Traffic");
	title.attr({font: "50px Arial", fill: "White"});
	
	//Line 1 Red To Blue
	red1 = total.circle(100, 125, 50);
	
	red1.attr({stroke: "none", fill: "#640A0A"});
	var arrow = total.g.arrow(195, 125, 50);
	arrow.attr({fill: "white"});
	
	blue1 = total.circle(300, 125, 50);
	blue1.attr({fill: "#10425D", stroke: "none"});
	
	text1 = total.text(450, 125, redToBlue_Total + " bytes");
	text1.attr({font: "35px Arial", fill: "White"});
	
	//Line 2 Blue To Red
	blue2 = total.circle(100, 235, 50);
	
	blue2.attr({stroke: "none", fill: "#10425D"});
	var arrow1 = total.g.arrow(195, 235, 50);
	arrow1.attr({fill: "white"});
	
	red2 = total.circle(300, 235, 50);
	red2.attr({stroke: "none", fill: "#640A0A"});
	
	text2 = total.text(450, 235, blueToRed_Total + " bytes");
	text2.attr({font: "35px Arial", fill: "White"});
	
	//Line 3 White to All
	white = total.circle(100, 345, 50);
	white.attr({fill: "white", stroke: "none"});
	
	var arrow2 = total.g.arrow(195, 345, 50);
	arrow2.attr({fill: "white"});
	
	littleBlue = total.circle(300, 315, 25);
	littleBlue.attr({stroke: "none", fill: "#10425D"});
	littleRed = total.circle(300, 370, 25);
	littleRed.attr({stroke: "none", fill: "#640A0A"});
	
	text3 = total.text(450, 345, whiteToAll_Total + " bytes");
	text3.attr({font: "35px Arial", fill: "White"});
};

//Draws titles for line graphs
drawText = function()
{
	textBlue = lgBlue.text(200, 10, "Blue Server Output");
	textBlue.attr({font: "20px Arial", fill: "White"});
	boxBlueToRed = lgBlue.rect(33, 309, 10, 10, 1);
	boxBlueToRed.attr({fill: "#640A0A", stroke: "White"});
	textBlueToRed = lgBlue.text(100, 315, "Blue to Red: " + bytes_blueToRed[bytes_blueToRed.length - 1]);
	textBlueToRed.attr({font: "15px Arial", fill:"white"});
	boxBlueToWhite = lgBlue.rect(228, 309, 10, 10, 1);
	boxBlueToWhite.attr({fill: "White", stroke: "White"});
	textBlueToWhite = lgBlue.text(300, 315, "Blue to White: " + bytes_blueToWhite[bytes_blueToWhite.length - 1]);
	textBlueToWhite.attr({font: "15px Arial", fill: "white"});
	
	
	textRed = lgRed.text(200, 10, "Red Server Output");
	textRed.attr({font: "20px Arial", fill: "White"});
	boxRedToBlue = lgRed.rect(33, 309, 10, 10, 1);
	boxRedToBlue.attr({fill: "#10425D", stroke: "white"});
	textRedToBlue = lgRed.text(100, 315, "Red to Blue: " + bytes_redToBlue[bytes_redToBlue.length - 1]);
	textRedToBlue.attr({font: "15px Arial", fill:"white"});
	boxRedToWhite = lgRed.rect(228, 309, 10, 10, 1);
	boxRedToWhite.attr({fill: "white", stroke: "white"});
	textRedToWhite = lgRed.text(300, 315, "Red to White: " + bytes_redToWhite[bytes_redToWhite.length - 1]);
	textRedToWhite.attr({font: "15px Arial", fill: "white"});
	
	textWhite = lgWhite.text(200, 10, "White Server Output");
	textWhite.attr({font: "20px Arial", fill: "White"});
	boxWhiteToAll = lgWhite.rect(33, 309, 10, 10, 1);
	boxWhiteToAll.attr({fill: "white", stroke: "white"});
	textWhiteToAll = lgWhite.text(100, 315, "White to All: " + bytes_White[bytes_White.length - 1]);
	textWhiteToAll.attr({font: "15px Arial", fill: "white"});
};
