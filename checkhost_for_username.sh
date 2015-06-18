#!/bin/bash

# define some vars here?
myTmpVar="$@"
myUsername=""


# function for logging in to each host and grabbing some output
check_host ()
{
	# read in hostname from conf.hosts, attempt to determine if it's valid or null
	while read myReadLine; do
		if [[ $myReadLine == "" ]] || [[ $myReadLine == \#* ]]; then
			echo "Skipping (probable) null host: \"$myReadLine\""
		else
			# probably a valid host, give it a gander logging in and checking for the username
#			for myTmpArg in $myUsername; do
			echo "Checking host \"$myReadLine\" for username(s) \"$myTmpArg\"..." >> report.log
			ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 $myReadLine "egrep -i \"$myTmpArg\" /etc/passwd /etc/group /etc/shadow" >> report.log
			echo "" >> report.log
			echo "" >> report.log
#			done
		fi
	done <~/bin/conf.hosts

}


# do something cool here vs shelling out to less :(
report_hosts ()
{
	#
	myTmpVar=""
	less report.log
}



#########################
### Main program body ###
#########################

# check that usernames were provided
if [ ! -n "$1" ]; then
	echo "My purpose in life is to log in to each host listed in conf.hosts and check for username(s). Feed me username(s) as either comma -or- space seperated values."
	echo "I will then log any results from /etc/passwd, /etc/group, and /etc/shadow to a file (~/report.log) for display to you."
	echo -e "\tExample 1: user1,user2,user3,user4"
	echo -e "\tExample 2: user1 user2 user3"
	echo -e "\tExample 3 (not recommended): user1,user2 user3 user4,user5"
	exit
fi

# remove the existing log file
echo "User search began on `date`" > report.log
echo "-------------------------------------------------" >> report.log
echo "" >> report.log
echo "" >> report.log

# replace any commas -or- spaces in the username string
myTmpVar=`echo "$myTmpVar" | sed 's/,/|/g'`
myUsername=`echo "$myTmpVar" | sed 's/ /|/g'`
echo $myUsername

# log into each host, grab output
check_host

echo "" >> report.log
echo "" >> report.log
echo "-------------------------------------------------" >> report.log
echo "User search completed on `date`" >> report.log

echo "Press Ctrl+C in the next 5 seconds or the log file will be shown."
echo -n "5.."
sleep 1
echo -n "4.."
sleep 1
echo -n "3.."
sleep 1
echo -n "2.."
sleep 1
echo -n "1.."
sleep 1
echo ""

# display all pretty like
report_hosts

