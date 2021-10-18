#!/bin/bash

####################################
# @author Seth Button-Mosher
# @author Alex Rogoff
# @author Aisha Khalid
####################################

spawnAll(){
	# permissions set to 644 by default so chmod just in case
	chmod 755 APM1
	chmod 755 APM2
	chmod 755 APM3
	chmod 755 APM4
	chmod 755 APM5
	chmod 755 APM6

	# store ip address then run applications
	## not sure if this is the right way to get ip address but it takes the
	## ip4 of inet
	ip=$(ifconfig | head -2 | tail -1 | awk '{print $2}')
	
	# run apps in the backround with &
	./APM1 $ip &
	./APM2 $ip &
	./APM3 $ip &
	./APM4 $ip &
	./APM5 $ip &
	./APM6 $ip &
}

# required function to collect system level metrics
sysMetrics(){

}

# required function to collect process level metrics 
procMetrics(){

}

killAll(){
	kill $(ps | grep APM1 | awk '{print $1}')
	kill $(ps | grep APM2 | awk '{print $1}')
	kill $(ps | grep APM3 | awk '{print $1}')
	kill $(ps | grep APM4 | awk '{print $1}')
	kill $(ps | grep APM5 | awk '{print $1}')
	kill $(ps | grep APM6 | awk '{print $1}')
}

spawnAll
## testing purposes... otherwise it will sometimes kill before the apps even run
sleep 2
killAll

####################################
# right now my output looks like this:
#
# 	[sb2232 ~/project1]$ ./APMTool.sh
# 	./APMTool.sh: line 36: 17043 Terminated              ./APM1 $ip
# 	./APMTool.sh: line 37: 17044 Terminated              ./APM2 $ip
# 	./APMTool.sh: line 38: 17045 Terminated              ./APM3 $ip
# 	./APMTool.sh: line 39: 17046 Terminated              ./APM4 $ip
# 	./APMTool.sh: line 45: 17047 Terminated              ./APM5 $ip
# 	[sb2232 ~/project1]$
####################################

