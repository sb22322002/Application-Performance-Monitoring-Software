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
	# Command to collect RX and TX data rates
	# Need to separate it out and only get the ens33 interface (Fields 7 & 9)
	ifstat -d 1 # "-d 1" sets to 1 second
	
	RX_RATE=1
	TX_RATE=1

	# Command to collect hard disk utilization
	# Need to separate it out and only get with the "/" mount (can do -T / i think)
	df -m # "-m" displays everything in Megabytes
	
	DISK_WRITES=1
	AVAIL_DISK_CAPACITY=1
	
	seconds=0

	echo "${seconds},${RX_RATE},${TX_RATE},${DISK_WRITES},${AVAIL_DISK_CAP}" >> system_metrics.csv
}

# required function to collect process level metrics 
procMetrics(){
	# Command to collect %CPU and %memory
	# Need to separate it out and only get it for the APM1-6
	ps -o %cpu,%mem,cmd #cmd displays for APM

	seconds=0
	
	# For loop to write each process's metrics in its own file
	for i in 1..6
	do
		CPU=0
		MEMORY=0
		echo "${seconds},${CPU},${MEMORY}" >> APM$i_metrics.csv
	done

}

cleanup(){
	kill $(ps | grep APM1 | awk '{print $1}')
	kill $(ps | grep APM2 | awk '{print $1}')
	kill $(ps | grep APM3 | awk '{print $1}')
	kill $(ps | grep APM4 | awk '{print $1}')
	kill $(ps | grep APM5 | awk '{print $1}')
	kill $(ps | grep APM6 | awk '{print $1}')

	echo "done"
}

# Trap - When the script ends it calls the cleanup function
# Note: This must stay on top!
trap cleanup EXIT

spawnAll

# While loop to run through each process need to do exit trap function
while [[ true ]]
do
	sysMetrics
	procMetrics
	sleep 5
	
done

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


