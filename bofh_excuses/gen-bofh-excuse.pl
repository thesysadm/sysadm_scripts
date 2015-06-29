#!/usr/bin/perl

#
# BOFH (c) Simon Travaglia 2009
# http://bofh.ntk.net/BOFH/
#
# Idea, and excuse list, taken from http://bofh.ntk.net/BOFH/bastard-excuse-board.php
#
# Script (c) Justin Tianen 2015
# https://github.com/thesysadm
#

## Set up the standard stuff
use strict;
use warnings;

## Declare my vars
### File path
my $filePath = 'gen-bofh-excuse_data.csv';
### File handle to parse from
my $handleExcuses;
### String of read in excuses, line by line
my $strExcuseLine = '';
### Array of excuses initially populated from $strExcuseLine
#### Yes, I 'probably' could do this in a better way if I was a Perl programmer; alas I am not.
my @arrExcuses1 = [];
my @arrExcuses2 = [];
my @arrExcuses3 = [];
my @arrExcuses4 = [];
## A simple counter
my $cntr=0;


## Let's open the excuse file!
open ($handleExcuses, '<', $filePath) or die "Could not open '$filePath' $!\n";

## Loop through the file and populate the array of excuses
while ($strExcuseLine = <$handleExcuses>) {
	## Eat it baby!
	chomp $strExcuseLine;

	## Split out each value by a ',' into own var, then add that to the array
	my ($col1, $col2, $col3, $col4) = split(',', $strExcuseLine);
	$arrExcuses1[$cntr] = $col1;
	$arrExcuses2[$cntr] = $col2;
	$arrExcuses3[$cntr] = $col3;
	$arrExcuses4[$cntr] = $col4;

	## Increment the array counter number by 1
	$cntr += 1;
}

## Close the file, data is now in an array.
close $handleExcuses;

## Strip any empty bits from each array
@arrExcuses1 = grep /\S/, @arrExcuses1;
@arrExcuses2 = grep /\S/, @arrExcuses2;
@arrExcuses3 = grep /\S/, @arrExcuses3;
@arrExcuses4 = grep /\S/, @arrExcuses4;

## Generate the random excuse
print "Today's excuse: '$arrExcuses1[rand @arrExcuses1] $arrExcuses2[rand @arrExcuses2] $arrExcuses3[rand @arrExcuses3] ($arrExcuses4[rand @arrExcuses4])'\n";

exit 0;

