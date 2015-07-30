#!/bin/bash

# Define some variables
## Array of all objects within /nfs/ftp; fully pathed
arrTmpObjects=(/nfs/ftp/*)
##
## Array of all objects within /nfs/ftp; name ONLY
arrDataObjects=(${arrTmpObjects[@]//\/nfs\/ftp\//})
##
## Array of IGNORED root objects, comma seperated
arrIgnoredObjects=(FOLDER1 FOLDER2 symlink3)
##
## The CURRENT object to rsync
strSyncDir=''
##
## Max rsync processes to run
### Multiply max desired by '3' when using rsync (it spawns 3 processes per job)
intRsyncMax=30
##
## How many rsync processes are currently running
intRsyncCurProc=0
##
## Path to the rsync binary
cmdRsync='rsync'
##
## String of options to pass to rsync, except for 'exclude'
strRsyncOptions='-a --delete-during --stats'
##
## String pattern to exclude
strRsyncExclude=''
##
## String for the log file
strRsyncLogFile=''


#
#
## Function for walking through every object in /nfs/ftp, checking if should be ignored, and launching an rsync (up to $intRsyncMax rsyncs) of the object
function folderLoop() {
	for strSyncDir in "${arrDataObjects[@]}"; do
		# Debug
		##printf "Checking object '$strSyncDir'.\n"

		# Determine if the object is a non-synced one
		if [[ "${arrIgnoredObjects[@]}" =~ "$strSyncDir" ]]; then
			# Debug
			printf "\t'${strSyncDir}' is an ignored object, skipping.\n\n"
		else
			# Launch a rsync of the object
			## But only if we've already less than intRsyncMax running
			if [ $intRsyncCurProc -lt $intRsyncMax ]; then
				runRsync
			else
				while [ $intRsyncCurProc -gt $intRsyncMax ]; do
					# Fake rsync, wait 2 seconds
					##sleep 2
					# Real rsync, wait 300 seconds (5 min)
					sleep 300

					# How many current rsync procs do we have
					intRsyncCurProc=`pgrep ${cmdRsync} | wc -l`
				done
				runRsync
			fi
		fi

		# How many current rsync procs do we have
		intRsyncCurProc=`pgrep ${cmdRsync} | wc -l`

	done
}


#
#
## Function for walking through the various rsyncs
function runRsync() {
	# Populate the log file
	if [ ! -d "/var/log/nas_rsync/`date +%Y%m%d`" ]; then
		mkdir "/var/log/nas_rsync/`date +%Y%m%d`"
	fi
	strRsyncLogFile="/var/log/nas_rsync/`date +%Y%m%d`/prod_ims13_${strSyncDir}.`date +%Y%m%d-%H%M`.log"

	# Debug
	##printf "\tSync initialized...\n"
	##printf "\tRunning '\
##${cmdRsync} ${strRsyncOptions} --exclude='${strRsyncExclude}' --log-file=${strRsyncLogFile} /nfs/ftp/${strSyncDir} /mnt/ftp/prod_ims13/ftp/ 1>${strRsyncLogFile} &
##\n"

	# Fake rsync
	##sleep 2 &
	# Real rsync
	${cmdRsync} ${strRsyncOptions} --exclude='${strRsyncExclude}' --log-file=${strRsyncLogFile} /nfs/ftp/${strSyncDir} /mnt/ftp/prod_ims13/ftp/ 1>${strRsyncLogFile} &
}


#
#
## Determine if there's any running rsyncs for this app
### If so, wait for them to complete before continuing
function checkRsync() {
	while pgrep -fl prod_ims13 >/dev/null; do
		printf "There are existing running syncs. Rechecking in 30 minutes.\n"
		sleep 1800
	done
	printf "Launching the next run...\n"
	printf "We have '${#arrDataObjects[@]}' objects to review.\n\n"
	printf "\tCompressing older files..."
	find /var/log/nas_rsync/ -type f -iname '*log' -exec gzip {} \;
	printf "done.\n\n"
}


#
#
## Start the Data object loop
checkRsync
folderLoop

