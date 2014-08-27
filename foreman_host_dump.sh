#!/bin/bash

printf "This assumes you've added your user and password to '~/tmp/password_file' in\n"
printf "the format '\$user:\$pass'. If not, break the script and do so first.\n\n"
printf "The script cycles from host 0 to host 1000.\n\n"
printf "The script will log all output to: ~/tmp/foreman_dump.txt\n\n\n"
sleep 3

printf "\tPlease wait while dumping Foreman hosts... "

cd ~/tmp
myAccount=`cat password_file`
>foreman_dump
for cntr in {0..1000}; do
printf "\n\n" >> foreman_dump
curl -s -k -u $myAccount https://foreman.dmotorworks.com/api/v2/hosts/$cntr/ >> foreman_dump.txt
done

printf "done\n\n"

