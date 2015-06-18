#!/bin/bash
# DK / July 28 2011
# Script to look for Cisco hits
usage()
{
    echo 
        echo "Usage:"
    echo
    echo "$0 <ip address you are searching for in the Cisco logs>"
    echo
        exit 1
}

# Print usage and exit if required arguments not passed
if [ $# -ne 1 ]
then
       usage
       exit 0
fi


grep $1 /var/log/hosts/*/`date +%Y.%m.%d.`local4
exit 0
