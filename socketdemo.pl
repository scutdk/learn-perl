#!/usr/bin/perl
use strict;
use IO::Socket::INET;

my $buf;
#my $host = "7d.v.iask.com";
my $host = "218.9.147.213";
my $sock = IO::Socket::INET->new("$host:80") or die($!);
my $request = "GET /7d.v.iask.com/16/2012121214/16c450k1355294134_05273.flv HTTP/1.0\r\n";
$request .= "Host: $host\r\n";
$request .= "Connect: close\r\n";
$request .= "User-Agent: Sina boke\r\n";
$request .= "\r\n";

print $sock $request or die($!);
#read($sock, $buf, 1024);
$sock->read($buf, 1024);
my ($header, $body) = split(/\r\n\r\n/, $buf);
print "$header\n\n";
print unpack("H*", $body);

