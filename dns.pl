#!/usr/bin/perl
use Data::Dumper;

my @servers = qw/8.8.8.8 61.139.2.69 8.8.4.4 202.106.182.153 218.30.108.100 58.63.238.177 60.28.164.133/;
my $hostname = shift @ARGV;
print $hostname, "\n";
my %results;
foreach my $server (@servers) {
    $results{$server} = LookupAddr($hostname, $server);
#print "$server => $results{$server}\n";
}

my %inv = reverse %results;
if (scalar keys %inv > 1 ) {
    print Data::Dumper->Dump( [ \%results ], ['results'] ), "\n";
#print Dumper(%results);
}
sub LookupAddr {
    my($hostname, $server) = @_;
    $nslookup = `which nslookup`;
    chomp $nslookup;
    open my $NSLOOK, '-|', "$nslookup $hostname $server";
    my @results;
    while (<$NSLOOK>) {
        next until (/^Name/);
        chomp ($result = <$NSLOOK>);
        $result =~ s/Address(es)?:\s*//;
        push @results, $result;
    }
#print @results, "\n";
    return join(',', @results);
}

