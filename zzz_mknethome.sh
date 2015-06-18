#!/bin/bash

myUser=$1

if [[ $myUser == "" ]]; then
	echo "Warning, no user entered. Exiting."
	exit 1
fi

echo "Creating home dir for $myUser..."
sleep 2

mkdir /nethome/$myUser
cp /etc/skel/.bash* /nethome/$myUser/
cd /nethome/$myUser/
chown $myUser: /nethome/$myUser/.bash*
chown $myUser: /nethome/$myUser/
chmod -R 755 /nethome/$myUser

stat /nethome/$myUser/
echo
echo
stat /nethome/

