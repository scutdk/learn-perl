#!/usr/bin/perl

use strict;
use IO::File;
#local $\ = "\n";

my $file = shift or die("I need a filename");
my $fh = IO::File->new($file, O_RDONLY) or die($!);
my %fh_hash;
while (<$fh>) {
    my $name = (split ":", $_)[0];
    my $name = lc $name;
    $fh_hash{$name} = IO::File->new($name.".info", O_CREAT|O_WRONLY|O_APPEND) unless exists $fh_hash{$name};
    print {$fh_hash{$name}} $_;
}
