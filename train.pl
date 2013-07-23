#!/usr/bin/perl
use MIME::Base64;
require "dezhi.pl";
use Data::Dumper;

my ($ua, $cookie_jar) = createua($ARGV[0]);
$ua->ssl_opts( verify_hostname => 0, SSL_verify_mode => 0 );
my $captcha = "";
do {
    $captcha = getcaptcha();
} while ($captcha =~ /recap/);
print "code is $captcha\n";

my $preloginurl = "https://dynamic.12306.cn/otsweb/loginAction.do?method=loginAysnSuggest";
my $prelogin_obj = $ua->post($preloginurl);
die $prelogin_obj->as_string() unless $prelogin_obj->is_success();
my ($loginRand) = $prelogin_obj->content() =~ /"loginRand":"(\d+)"/;

my %loginpost = ('loginRand' => $loginRand,
                'refundLogin' => 'N',
                'refundFlag'  => 'Y',
                'loginUser.user_name' => 'xdz0611',
                'nameErrorFocus' => '',
                'user.password' => 'NKA9qLJ9',
                'passwordErrorFocus' => '',
                'randCode' => "$captcha",
                'randErrorFocus' => '',
);
print Dumper(\%loginpost);

my $loginurl = "https://dynamic.12306.cn/otsweb/loginAction.do?method=login";

my $dologin = $ua->post($loginurl, \%loginpost);
if ($dologin->is_success()) {
#print $dologin->as_string();
#sleep 1;
    print $dologin->as_string();
} else {
    print $dologin->as_string();
    die($dologin->code()."do login failed");
}   

sub getcaptcha {
    #open(my $fh, ">", "/var/www/html/dezhi/cap.jpg") or die($!);
    my $loginform = "http://www.12306.cn/mormhweb/kyfw/";
    my $rand = rand 1;
    my $res = $ua->get($loginform);
    if ($res->is_success()) {
        my $jpgres = $ua->get("https://dynamic.12306.cn/otsweb/passCodeAction.do?rand=sjrand");
        if ($jpgres->is_success()) {
#print $fh $jpgres->content();
            my $img_base64 = encode_base64($jpgres->content());
#my %form = ("img" => $jpgres->content())g
            my %form = ("img" => $img_base64);
            $ua->post("http://123.125.104.101/dezhi/img.php?filename=${rand}.jpg", \%form);
            print "http://123.125.104.101/dezhi/img/${rand}.jpg\n";
            print "enter \"recap\" to get captcha again or enter the captcha code to continue login\n";
            #close $fh;
        } else {
            print $jpgres->as_string();
            die("can't get captcha code\n");
        }
    } else {
        die("can't get login form\n");
    }
    chomp (my $captcha = <STDIN>);
    return $captcha;
}
