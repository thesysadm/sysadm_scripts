#!/bin/bash
#
# Script to remove any VNX psuedo devices and then the backing disks
#
# Guides:
# http://sysadmin-tricks.blogspot.com/2013/12/remove-lun-from-linux-and-powerpath.html
# http://www.thegeekstuff.com/2010/10/powermt-command-examples/
#

# Get an array of all VNX psuedo names
arrVNXDevices=`powermt display class=vnx dev=all | grep 'Pseudo name=' | cut -d'=' -f2`

# Start a loop through the VNX psuedo names
for myDevice in $arrVNXDevices; do
	# Build an array of every disk within the selected device
	arrDisks=`powermt display class=vnx dev=$myDevice | awk '{print $3}' | grep 'sd[a-za-z]'`

	# Start a loop through the array of disks belonging to a VNX device
	for myDisk in $arrDisks; do
		# DEBUG
		printf "The VNX device '$myDevice' has the disk '$myDisk'.\n"

		# Pause 5 seconds, remove the disk from PowerPath, remove the disk from the OS
		sleep 5 && \
			powert remove class=vnx dev=$myDisk && \
			echo 1 > /sys/block/$myDisk/device/delete
	done

	# Delete the VNX psuedo device
	powermt remove class=vnx dev=$myDevice

done

# Release all removed block devices
powermt release
powermt save

