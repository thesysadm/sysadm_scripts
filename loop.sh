#!/bin/bash

# set up some vars
myHostFile=""
myFS_Path=""
myHostFile=""
myHost=""


check_host() {
	# read in the full host list and start a loop through them
	myHostFile=$(<$myFS_Path)
	for myHost in $myHostFile; do
		# make sure I've a valid host, else crap myself
		if [[ $myHost == "" ]] || [[ $myHost == \#* ]]; then
			echo "Skipping (probable) null host: \"$myHost\""
		else
			# SSH into the host, run `zsh --version` and hope for output
			echo "Checking host '$myHost'"
			# do something awesome here
			#ssh -q -oBatchMode=yes -oStrictHostKeyChecking=no -oConnectTimeout=1 $myHost "cat /usr/openv/netbackup/bp.conf | grep CLI"
		fi
	done
}


echo "Starting... "
myFS_Path=$@
if [[ -z $myFS_Path ]] || [[ ! -e $myFS_Path ]]; then
	echo -e "\tError- please pass a valid list of hosts!"
	echo ""
else
	rm ~/bin/bad_hosts
	check_host
fi

