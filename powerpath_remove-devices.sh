#!/bin/bash
powermt display dev=all > /tmp/tianenj
printf "Remove Devices from /tmp/tianenj that you do not want to remove from the host\n"
read x
vim /tmp/tianenj 
for i in `grep emcpower /tmp/tianenj | cut -d= -f2`; do   powermt remove dev=$i; done
powermt release
for i in `grep sd /tmp/tianenj | awk '{print $3}'`; do  echo 1 > /sys/block/$i/device/delete; done
powermt display
powermt check
powermt display
powermt display dev=all

