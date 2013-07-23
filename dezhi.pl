use LWP::UserAgent;
use HTTP::Cookies;

sub createua {
    my $cookiefile = shift @_;
    my $cookie_jar = HTTP::Cookies->new(
        file => "$cookiefile",
        autosave => 1,
        ignore_discard => 1,
    );
    my $ua = LWP::UserAgent->new();
    push @{ $ua->requests_redirectable }, 'POST';
    $ua->agent("Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.21 (KHTML, like Gecko) Chrome/25.0.1349.2 Safari/537.21");
    $ua->timeout(5);
    $ua->cookie_jar($cookie_jar);
    return ($ua, $cookie_jar);
}

1
