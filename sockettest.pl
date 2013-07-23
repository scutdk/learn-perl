use IO::Socket::INET;
    $sock = IO::Socket::INET->new(PeerAddr  => "www.baidu.com",
                PeerPort => '80',
                Proto => 'tcp',
                ) or die($!);
    print $sock->sockport();
