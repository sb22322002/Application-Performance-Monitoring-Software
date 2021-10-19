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
	ip=$(ifconfig | head -2 | tail -1 | awk '{print $2}')
	
	# run apps in the backround with &
	./APM1 $ip &
	./APM2 $ip &
	./APM3 $ip &
	./APM4 $ip &
	./APM5 $ip &
	./APM6 $ip &

	# initialize variables to keep track of time
	time=0
	
	# create new files system_metrics.csv and <proc_name>_metrics.csv
	echo -n "" > system_metrics.csv
	for i in {1..6}
	do
		echo -n "" > "APM${i}_metrics.csv"
	done
}

# required function to collect system level metrics
sysMetrics(){
	# Command to collect RX and TX data rates
	# Need to separate it out and only get the ens33 interface (Fields 7 & 9)
	# "-d 1" sets to 1 second
	ifstat -d 1 > /dev/null 2>&1
	
	RX_RATE=$(ifstat| grep ens | awk '{print $7}')
	TX_RATE=$(ifstat| grep ens | awk '{print $9}')

	# Command to collect hard disk utilization
	# Need to separate it out and only get with the "/" mount (can do -T / i think)
	## df -m # "-m" displays everything in Megabytes
	
	DISK_WRITES=$(iostat | grep sda | awk '{print $4}')
	AVAIL_DISK_CAP=$(df -mT / | tail -1 | awk '{print $5}')

	echo "${1},${RX_RATE},${TX_RATE},${DISK_WRITES},${AVAIL_DISK_CAP}" >> system_metrics.csv
}

# required function to collect process level metrics 
procMetrics(){
	# Command to collect %CPU and %memory
	# Need to separate it out and only get it for the APM1-6

	## ps -o %cpu,%mem,cmd # cmd displays for APM

	# For loop to write each process's metrics in its own file
	for i in {1..6}
	do
		CPU=$(ps -o %cpu,cmd | grep "APM$i" | head -1 | awk '{print $1}')
		MEMORY=$(ps -o %mem,cmd | grep "APM$i" | head -1 | awk '{print $1}')
		echo "${1},${CPU},${MEMORY}" >> "APM${i}_metrics.csv"
	done
	
	
}

cleanup(){
	#############################################################
	# trying to get rid of the messages at the end when killing jobs
	#############################################################
	kill $(ps | grep APM1 | awk '{$1}') 2>/dev/null 
	kill $(ps | grep APM2 | awk '{$1}') 2>/dev/null
	kill $(ps | grep APM3 | awk '{$1}') 2>/dev/null
	kill $(ps | grep APM4 | awk '{$1}') 2>/dev/null
	kill $(ps | grep APM5 | awk '{$1}') 2>/dev/null
	kill $(ps | grep APM6 | awk '{$1}') 2>/dev/null

	echo "Complete"
}

# Trap - When the script ends it calls the cleanup function
# Note: This must stay on top!
trap cleanup EXIT

spawnAll

# While loop to run through each process need to do exit trap function
while [[ true ]]
do
	sysMetrics "$time"
	procMetrics "$time"

	echo "Metrics collected - TIME: $time seconds"

	sleep 5
	time=$(echo "$time+5" | bc)
done
