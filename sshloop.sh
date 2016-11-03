#!/bin/bash

# This is a fairly simple BASH script to iterate through either a full subnet or a
# single host via SSH and execute a command. All output of the command is always
# logged to /tmp/sshloop.$DATE.log and opened in 'less' as the final step, allowing one
# to immediately review the command result.

# Licence: BSD (3-Clause) License
# Author:  justin@em.ails.us
# Source:  https://github.com/thesysadm/sysadm_scripts

#
# set up some vars
## var1: input Subnet
tmpSubnet=$1
## var2: command to run on remote SSH server
strSSHCmd=$2
## array which $tmpSubnet is converted to
arrSubnet=()
## log file
myLog=/tmp/sshloop.`date +%Y%m%d-%H%M`.log


#
# Check for some sort of data in both vars and, if not, print out the help
if [ "$strSSHCmd" == "" ]; then
  printf "#################################################################################\n"
  printf "|\t\t\t\tSSHLoop Help\t\t\t\t\t|\n"
  printf "#################################################################################\n"
  printf "This is a fairly simple BASH script to iterate through either a full subnet or a\n"
  printf "single host via SSH and execute a command. All output of the command is always\n"
  printf "logged to /tmp/sshloop.$DATE.log and opened in 'less' as the final step, allowing one\n"
  printf "to immediately review the command result.\n\n"

  printf "SSHLoop executes using these SSH parameters:\n"
  printf "\t* BatchMode=yes\n"
  printf "\t* StrictHostKeyChecking=no\n"
  printf "\t* ConnectTimeout=1\n"
  printf "\t* UserKnownHostsFile=/dev/null\n\n"

  printf "SSHLoop requires 2 parameters to run:\n"
  printf "\t* Either a /24 or /23 subnet or a single IP.\n"
  printf "\t* Command to execute, enclosed in quotes.\n\n"
  printf "Subnet example:\tsshloop.sh 192.168.144.0/24 \"ls -al /usr/local/java\"\n"
  printf "IP example:\tsshloop.sh 192.168.2.66 \"cat /etc/issue\"\n"

  printf "\n"
  exit 0
fi

#
# Convert the input Subnet into an array
IFS='.' read -a arrSubnet <<< "$tmpSubnet"

#
# Nastily try to discern if we were passed a full subnet or a single host
case ${arrSubnet[3]} in
  '0/24')
    # Thinks it's SSHing across a /24 subnet
    intLoopCntMax=1
    ;;
  '0/23')
    # Thinks it's SSHing across a /23 subnet
    intLoopCntMax=2
    ;;
  *)
    # Thinks it's SSHing to a single host
    intLoopCntMax=0
    ;;
esac

#
# Print out what this script should be doing
printf "#########################################################################\n"
printf "|\t\t\t\tSSHLoop\t\t\t\t\t|\n"
printf "| SSHing to:\t$tmpSubnet\n"
printf "| Executing:\t$strSSHCmd\n"
printf "#########################################################################\n\n"

#
# Do the SSH magic!
#
# Try to discern if running command on either a single server or across a subnet
printf "Logging to file '${myLog}'.\n"

if [ $intLoopCntMax = 0 ]; then
  ## Script thinks this is a single server
  ### Write the log
  printf "Connecting:\t$tmpSubnet\n" >> $myLog
  printf "CMD output:\t" >> $myLog
  ### SSH and execute the command
  ssh -q -oBatchMode=yes -oStrictHostKeyChecking=no -oConnectTimeout=1 -oUserKnownHostsFile=/dev/null $tmpSubnet "$strSSHCmd" &>> $myLog
  ### Finish the log entry line
  printf "\n\n" >> $myLog

else
  ## Script thinks this is a /24 or /23 subnet
  intLoopCnt=0
  ### For those who care, print out a foolish 'please wait' message
  printf "\n\tPlease wait, executing SSH loop across the subnet(s)...\n\n\n"
  while [ $intLoopCnt -lt $intLoopCntMax ]; do
    ### Counter from 0 to 255 for the IP's last octet
    for IP in {0..255}; do
      ### Write the log
      printf "Connecting:\t${arrSubnet[0]}.${arrSubnet[1]}.${arrSubnet[2]}.$IP\n" >> $myLog
      printf "CMD output:\t" >> $myLog
      ### SSH and execute the command
      ssh -t -q -oBatchMode=yes -oStrictHostKeyChecking=no -oConnectTimeout=1 -oUserKnownHostsFile=/dev/null ${arrSubnet[0]}.${arrSubnet[1]}.${arrSubnet[2]}.$IP "$strSSHCmd" &>> $myLog
      ### Finish the log entry line
      printf "\n\n" >> $myLog
    done
    # Increment loop counter
    let intLoopCnt=intLoopCnt+1
    # Increment third IP octet by 1 to go from a /24 to a /23
    let arrSubnet[2]=${arrSubnet[2]}+1
  done

fi

#
# Open log file in a 'less' process for review
less $myLog

exit 0
#EOF
