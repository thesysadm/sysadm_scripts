#!/bin/perl

#
# (c) 1994-2000 Jeff Ballard.
#
##
## Modified by J Tianen 20150629
##

# Open the excuses file and grab one at "random".
open(F, "/srv/http/vhosts/sysadm.pw/bofh/excuses") or die "Content-type: text/html\n\nAck...can't read the excuse file! Don't expect the rest to work.\n";

srand(time);

$number=0;
@excuse = ();
while( $excuse[$number] = <F>) {
	$number++;
}

$thisexcuse = $excuse[ (rand(1000)*$$)%($number+1) ];


## Display the results
print "Content-type: text/html\n";
print "\n";
print "<title>\"Bastard Operator From Hell\"-Style Excuses</title>\n";
print "<center><font size = \"+2\">The \"BOFH\"-style excuse generator.</font>";
print "<br><br><hr><br>";
print "The cause of the problem is:<br>";
print "<font size = \"+2\">";
print "$thisexcuse</font>";
print "<br><br><hr>";

## Exit gracefully
exit(0);

