#!/bin/bash

# Change 'SUBNET' for something like '192.168.0'
mySubnet='<SUBNET>'

# Change 'FORWARD_ZONE_FILE' for something like 'microsoft.com'
# Change 'DOMAIN' to, most likely, match 'FORWARD_ZONE_FILE'
grep $mySubnet <FORWARD_ZONE_FILE> | awk '{print $3 "\t\t" $1".<DOMAIN>."}' | grep -v ';' | sort > /tmp/forward

awk '{print var "." $1 "\t\t" $3}' var="$mySubnet" reverse/${mySubnet} | egrep "${mySubnet}.([0-9])?([0-9])?[0-9]\b" | egrep -v 'SOA' | sort > /tmp/reverse

diff -u /tmp/forward /tmp/reverse

