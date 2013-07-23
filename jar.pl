use strict;
use LWP::UserAgent;
use HTTP::Cookies;
my $cookie_jar = HTTP::Cookies->new(
    file => "./lwp_cookies.dat",
    autosave => 1,
);
my $ua = LWP::UserAgent->new();
$ua->cookie_jar($cookie_jar);
$ua->get("http://www.baidu.com");
