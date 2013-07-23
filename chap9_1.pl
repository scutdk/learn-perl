#!/usr/bin/perl

my @output = 
#map { $_->[0] }
    sort { $b->[1] <=> $a->[1] } 
    map { [$_, -s $_] }
    glob "/bin/*";

print map { sprintf("    %-30s %-10d\n", $_->[0], $_->[1]) } @output;
