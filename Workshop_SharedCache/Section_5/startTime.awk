#!/bin/awk -f

/Tomcat run starting at/	{ startTime = $5+0;
		  		}

/Server start/			{ endTimeString = $1 " " $2;
				  cmd="date -d \"" endTimeString "\" +%s%N";
				  cmd | getline endTime;
       				  print "Server initiated " startTime ", up at " endTime;
				  diff = (endTime - startTime) / 1000000;
				  print "Full start time is " diff " ms";
				}
