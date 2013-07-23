#!/usr/bin/perl

use strict;
use IO::File;
use IO::Tee;
use IO::Scalar;
use POSIX qw/strftime/;
local $\ = "\n";

my $date = strftime("%Y-%m-%d", localtime(time));
my @week = qw/Sun Mon Tue Wed Thu Fri Sat/;
my $wday = (localtime time)[6];
print $week[$wday];

my $fh = IO::File->new("./day.txt", O_CREAT|O_WRONLY|O_APPEND) or die($!);
my $string_log = '';
my $string_fh = IO::Scalar->new(\$string_log, O_RDWR) or die($!);
my $tee_fh = IO::Tee->new($fh, $string_fh) or die($!);

my $user_input = get_option();
if ($user_input eq '1') {
    print $fh $date,$week[$wday];
} elsif ($user_input eq '2') {
    print $string_fh $date,$week[$wday];
} elsif ($user_input eq '3') {
    print $tee_fh $date,$week[$wday];
} else {
    print "wrong choice!!!";
}

if ($user_input eq '2' or $user_input eq '3') {
    print "2 or 3";
    print "strlog: $string_log";
    print while (<$string_fh>);
}


sub get_option {
    print "1. print to file day.txt";
    print "2. print to a scalar";
    print "3. print to both";
    print "pls enter your choice:[123] ";
    my $input = <>;
    chomp $input;
    die("wrong input ") unless $input =~ m/[123]/;
    $input =~ s/[^123]//;
    return $input;
}
