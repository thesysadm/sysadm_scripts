#!/bin/bash
# Shell Script To List All Top Hitting IP Address to your webserver.
# This may be useful to catch spammers and scrappers.
# -------------------------------------------------------------------------
# Copyright (c) 2004 nixCraft project <http://www.cyberciti.biz/fb/>
# This script is licensed under GNU GPL version 2.0 or above
# -------------------------------------------------------------------------
# This script is part of nixCraft shell script collection (NSSC)
# Visit http://bash.cyberciti.biz/ for more information.
# ----------------------------------------------------------------------
 
# where to store final report?
##DEST=/var/www/reports/ips
 
# domain name
DOM=$1
 
# log file location
LOGFILE=/var/log/httpd/$DOM/access_log
 
# die if no domain name given
[ $# -eq 0 ] && exit 1
 
# make dir
##[ ! -d $DEST ] && mkdir -p $DEST
 
# ok, go though log file and create report
if [ -f $LOGFILE ]
then
echo "Processing log for $DOM..."
#awk '{ print $1}' $LOGFILE | sort | uniq -c | sort -nr > $DEST/$DOM.txt
awk '{ print $2}' $LOGFILE | sort | uniq -c | sort -nr
##echo "Report written to $DEST/$DOM.txt"
fi
