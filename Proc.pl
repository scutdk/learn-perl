#!/usr/bin/perl

use Proc::ProcessTable;

my $tobj = new Proc::ProcessTable;
my $proctable = $tobj->table();

my $proctable = $tobj->table();
foreach my $process (@$proctable) {
    print $process->pid . "\t" . getpwuid( $process->uid ) . "\n";
}

my @fields = $tobj->fields();
print "@fields\n";

