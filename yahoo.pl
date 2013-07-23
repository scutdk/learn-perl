#!/usr/bin/perl
use strict;
use Data::Dumper;
require "dezhi.pl";
my ($ua, $cookie_jar) = createua($ARGV[0]);
my $res = $ua->get("https://login.yahoo.com");
my ($challenge) = $res->content =~ /".challenge"\s*value="(\S+)"/;
my ($formu) = $res->content =~ /name=".u"\s*value="(\S+)"/;
my %logininfo = (".tries" => '1',
        ".src" => 'my',
        ".md5" => '',
        ".hash" => '',
        ".js" => '',
        ".last" => '',
        "promo" => '',
        ".intl" => 'us',
        ".lang" => 'en-US',
        ".bypass" => '',
        ".partner" => '',
        ".u" => "$formu",
        ".v" => '0',
        ".challenge" => "$challenge",
        ".yplus" => '',
        ".emailCode" => '',
        "pkg" => '',
        "stepid" => '',
        ".ev" => '',
        "hasMsgr" => '0',
        ".chkP" => 'Y',
        ".done" => 'http://my.yahoo.com/?_bc=1',
        ".pd" => 'my_ver=0&c=&ivt=&sg=',
        ".ws" => '1',
        ".cp" => '0',
        "nr" => '0',
        "pad" => '5',
        "aad" => '5',
        "login" => 'scutdk',
        "passwd" => '456123abc',
        ".persistent" => 'y',
        ".save" => '',
        "passwd_raw" => '');

$res = $ua->post("https://login.yahoo.com/config/login?", \%logininfo);
#print Dumper(\%logininfo);
$res = $ua->get("http://my.yahoo.com");
print $res->as_string();
