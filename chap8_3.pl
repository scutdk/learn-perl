#!/usr/bin/perl
use strict;
use IO::Dir;
local $\ = "\n";

die("I need at least a dirname") unless @ARGV > 0;
foreach (@ARGV) {
    if (-d $_) {
        my $dir_fh = IO::Dir->new($_) or die($!);
        while (my $content = $dir_fh->read()) {
            print $content;
        }
        $dir_fh->close();
    } else {
        print "Not a dir : $_";
    }
}
