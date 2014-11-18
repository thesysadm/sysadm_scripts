#!/bin/bash

#
## Input must be an IP else bail with usage
myIP=$@
if [ ! -n "$myIP" ]; then
  printf "__Help__\n"
  printf "  Requires a single IP address to be passed to the script.\n\n"
  exit 1
fi

#
## DEBUGGING
#printf "searching for ip '$myIP' in netstat!\n\n"

#
## Get any PID(s) for the IP
myPID=`netstat -plan 2>/dev/null | grep "$myIP" | awk '{print $7}' | cut -d'/' -f1`

#
## Enter a loop for every PID returned
for i in $myPID; do
  #
  ## DEBUGGING
  #printf "got PID '$i'!\n"

  #
  ## Try to determine the connected time and display it
  myTime=`ps -eo pid,etime | grep "$i" | awk '{print $2}'`
  printf "You've been connected to '$myIP' for '$myTime'.\n"

done

unset myIP
unset myPID
unset myTime
unset i

exit 0

