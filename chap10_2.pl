#!/usr/bin/perl

use strict;
require "chap10_1.pm";

my($sec, $min, $hour, $mday, $mon, $year, $wday) = localtime(time);
my $wdaystr = Oogaboogoo::date::day($wday);
my $monthstr = Oogaboogoo::date::mon($mon);
my $year += 1900; 
print "Today is $wdaystr, $monthstr $mday, $year\n";


