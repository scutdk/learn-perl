#!/usr/bin/perl
use Getopt::Std;
use Data::Dumper;
getopts(":a:p:", \%args);
if (!defined($args{'a'}) or !defined($args{'p'})) {
    print "Usage: perl $0 -a <ip> -p <port>\n";
} else {
    print Dumper(\%args);
}

