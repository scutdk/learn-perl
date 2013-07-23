open( my $HOSTS, '<', '/etc/hosts' ) or die "Unable to open host file:$!\n";
my %addrs;
my %names;
while ( defined( $_ = <$HOSTS> ) ) {
    next if /^#/;    # skip comments lines
    next if /^\s*$/; # skip empty lines
    s/\s*#.*$//;     # delete in-line comments and preceding whitespace
    chomp;
    my ( $ip, @names ) = split;
    die "The IP address $ip already seen!\n" if ( exists $addrs{$ip} );
    $addrs{$ip} = [@names];
    for (@names) {
        die "The host name $_ already seen!\n" if ( exists $names{lc $_} );
        $names{lc $_} = $ip;
    }
}
close $HOSTS;
