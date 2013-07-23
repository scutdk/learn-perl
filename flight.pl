#!/usr/bin/perl
use strict;
use JSON;
use Data::Dumper;
use Encode;
use Getopt::Std;
use Time::HiRes qw(sleep time);
use MIME::Base64;  
require "dezhi.pl";

$| = 1;

my %input;
getopts("c:p:", \%input);
unless ($input{'c'} && $input{'p'}) {
    print "Usage: $0 -c cookiefile -p passinfofile\n";
    exit(1);
}

my ($ua, $cookie_jar) = createua($input{'c'});
my($fltDate, $airTax, $fuelTax, $username, $pass, $flightid, $ticketNum, $pass1name, $id1, $pass2name, $id2) = getPassInfo($input{'p'});

if (-f $input{'c'}) {
    $cookie_jar->load($input{'c'});
    checkcookies();
}

sub checkcookies {
    my $url = "http://www.capitalairlines.com.cn/frontend/users/register/showinfo.action";
    my $res = $ua->get($url);
    die("code: $res->code(), can't check cookies, get page error\n") unless $res->is_success();
    dologin() unless ($res->content() =~ /$username/i);
}

my($userid, $person, $email, $cell);
getUserInfo();

#my ($lostcabin, $routesid) = getflight();
#while ($lostcabin == -1) {
#    sleep 0.1;
#    ($lostcabin, $routesid) = getflight();
#}
my $ordercontent = "";
do {
	$ordercontent = placeorder();
} while ($ordercontent !~ /$id1/);
print "place order ok\n";

sub dologin {
    my $captcha = "";
    do {
        $captcha = getcaptcha();
    } while ($captcha =~ /recap/);
    print "code is $captcha\n";

    my $loginurl = "http://www.capitalairlines.com.cn/login.action";
    my $loginrefer = "http://www.capitalairlines.com.cn/login.action";
    my %loginpost = ("userName" => "$username",
                    "password" => "$pass",
                    "j_captcha_response" => "$captcha");
    print Dumper(\%loginpost);
    my $dologin = $ua->post($loginurl, \%loginpost);
    if ($dologin->is_success()) {
#print $dologin->as_string();
        sleep 1;
    } else {
        print $dologin->as_string();
        die($dologin->code()."do login failed");
    }
    my $logindone = $ua->get("http://www.capitalairlines.com.cn/");
    open(my $fhout, ">", "./cap.html") or die($!);
    if ($logindone->is_success()) {
        $cookie_jar->save();
        print $fhout $logindone->content();
    }
}

sub getflight {
    my($lostcabin, $routesid);
    my $flighturl = "http://www.capitalairlines.com.cn/frontend/groupbuying/groupindex/groupindex!doIndexDetail.action?detailId=$flightid";
    print "$flighturl\n";
    my $res = $ua->get("$flighturl");
    if ($res->is_success()) {
#print "res ok\n";
#print $res->content();
        my ($flt) = $res->content() =~ /temptitleId"\s*>([^<]*)</;
        my ($routesStr) = $res->content() =~ m/var\s*routesStr\s*=\s*"(.*)";\s*$/m;
        $routesStr =~ s/'/"/g;
        $routesStr =~ s/root/"root"/;
#print "$routesStr\n";
        my $jsonobj = decode_json($routesStr);
#print Dumper(@{ $jsonobj->{'root'} }[0]);
        print "$flt: Current max date ${ $jsonobj->{'root'} }[-1]->{'fltDate'}, status: ${ $jsonobj->{'root'} }[-1]->{'status'}, price:${ $jsonobj->{'root'} }[-1]->{'price'} ".time()."\n\n";
        foreach (@{ $jsonobj->{'root'} }) {
            if ($_->{'fltDate'} =~ /$fltDate/) {
#print Dumper($_);
                return (-1, -1) unless $_->{'status'} =~ /OPEN_FOR_SALE/;
                $lostcabin = $_->{'lostcabin'};
                $routesid = $_->{'id'};
                my $lastpage = "http://www.capitalairlines.com.cn/frontend/groupbuying/order/grouporder!passengerInfo.action?routesId=$routesid&cabinNum=$lostcabin";
                print "$lastpage\n";
                return ($lostcabin, $routesid);
            }
        }
        return (-1, -1);
    } else {
        print $res->code();
    }
}

sub getUserInfo {
    my $page = "http://www.capitalairlines.com.cn/frontend/groupbuying/order/grouporder!passengerInfo.action?routesId=7015&cabinNum=15";
    my $lastres = $ua->get($page);
    my $page = $lastres->content();
#($fuelTax) = $page =~ /fuelTax1"\s*type="hidden"\s*value="([\d\.]+)"/;
#($airTax) = $page =~ /airportTax1"\s*type="hidden"\s*value="([\d\.]+)"/;
#($username) = $page =~ /"condition\.userLogin"\s*id="contactName"\s*type="hidden"\s*class="ipt1"\s*value="(\w+)"/;
    ($userid) = $page =~ /condition\.userId"\s*id="contactId"\s*type="hidden"\s*class="ipt1"\s*value="(\d+)"/;
    ($person) = $page =~ /condition\.person"\s*id="contactName"\s*type="text"\s*class="ipt1"\s*value="([^"]+)"/;
    ($email) = $page =~ /contactEmail"\s*type="text"\s*class="ipt1"\s*value="([\w@\.]+)"/;
    ($cell) = $page =~ /contactMobile"\s*type="text"\s*class="ipt1"\s*readonly="readonly"\s*value="(\d+)"/;
    print "$fuelTax, $airTax, $username, $userid, $person, $email, $cell\n";
}


sub getPassInfo {
    my  $filename = shift @_ or die("you must supply a filename\n");
    open(my $fh, "<", $filename);
    while (<$fh>) {
        next if /#/;
        my($fltDate, $airTax, $fuelTax, $username, $pass, $flightid, $ticketNum, $pass1name, $id1, $pass2name, $id2) = split(" ", $_);
        $username = uc($username);
        close($fh);
        print "$fltDate, $airTax, $fuelTax, $username, $pass, $flightid, $ticketNum, $pass1name, $id1, $pass2name, $id2\n";
        return ($fltDate, $airTax, $fuelTax, $username, $pass, $flightid, $ticketNum, $pass1name, $id1, $pass2name, $id2);
    }
}

sub placeorder {
    my %postform = ("routesId" =>                    '5921',
                    "airportTax" =>                  $airTax,
                    "fuelTax" =>                     $fuelTax,
                    "pass1box" =>                    "unchecked",
                    "pass2box" =>                    "unchecked",
                    "ticketNum" =>                   $ticketNum,
                    "pass1.name" =>                  $pass1name,
                    "pass1.certificateType" =>       "NI",
                    "pass1.certificateNo" =>         $id1,
                    "pass2.name" =>                  $pass2name,
                    "pass2.certificateType" =>       "NI",
                    "pass2.certificateNo" =>         $id2,
                    "condition.userId" =>            $userid,
                    "condition.userLogin" =>         $username,
                    "condition.person" =>            $person,
                    "condition.userEmail" =>         $email,
                    "condition.userMobileNo" =>      $cell,
                    "condition.phone"        =>     "",
                    "confirmBox"             =>     "checkbox");
    print Dumper(\%postform);
    my $posturl = "http://www.capitalairlines.com.cn/frontend/groupbuying/order/grouporder!submitOrder.action";
    my $res = $ua->post($posturl, \%postform);
    if ($res->is_success()) {
		return $res->content();
    }
}

sub testcookie {
    my $testurl = "http://123.125.104.101/dezhi/cookie.php";
    $ua->get($testurl);
    my $res2 = $ua->get($testurl);
    print $res2->as_string();
    exit();
}

sub getcaptcha {
    #open(my $fh, ">", "/var/www/html/dezhi/cap.jpg") or die($!);
    my $loginform = "http://www.capitalairlines.com.cn/login.action";
    my $rand = rand 1;
    my $res = $ua->get($loginform);
    if ($res->is_success()) {
        my $jpgres = $ua->get("http://www.capitalairlines.com.cn/jcaptcha?.tmp=$rand");
        if ($jpgres->is_success()) {
#print $fh $jpgres->content();
            my $img_base64 = encode_base64($jpgres->content());
#my %form = ("img" => $jpgres->content());
            my %form = ("img" => $img_base64);
            $ua->post("http://123.125.104.101/dezhi/img.php?filename=${rand}.jpg", \%form);
            print "http://123.125.104.101/dezhi/img/${rand}.jpg\n";
            print "enter \"recap\" to get captcha again or enter the captcha code to continue login\n";
            #close $fh;
        } else {
            die("can't get captcha code\n");
        }
    } else {
        die("can't get login form\n");
        print $res->as_string();
    }
    chomp (my $captcha = <STDIN>);
    return $captcha;
}

sub testJSON {
    my $routesStr = '{"root":[{"id":"5140","price":"100.00","oprice":"2200.00","discount":"0.45","fltNum":"JD5196","fltDate":"2012-12-21","fltDepTime":"20:35","fltArrTime":"0:35","minPersons":"1","tktNum":"3","endPersons":"3","saleStartDate":"2012-12-07 00:00:00.0","status":"SALE_FINISHED","lostcabin":"0","saleEndDate":"2012-12-14 23:59:59.0"},{"id":"5144","price":"100.00","oprice":"2200.00","discount":"0.45","fltNum":"JD5196","fltDate":"2012-12-22","fltDepTime":"20:35","fltArrTime":"0:35","minPersons":"1","tktNum":"2","endPersons":"2","saleStartDate":"2012-12-08 00:00:00.0","status":"SALE_FINISHED","lostcabin":"0","saleEndDate":"2012-12-15 23:59:59.0"},{"id":"5147","price":"100.00","oprice":"2200.00","discount":"0.45","fltNum":"JD5196","fltDate":"2012-12-23","fltDepTime":"20:35","fltArrTime":"0:35","minPersons":"1","tktNum":"2","endPersons":"2","saleStartDate":"2012-12-09 00:00:00.0","status":"SALE_FINISHED","lostcabin":"0","saleEndDate":"2012-12-16 23:59:59.0"},{"id":"5861","price":"100.00","oprice":"2200.00","discount":"0.45","fltNum":"JD5196","fltDate":"2012-12-24","fltDepTime":"20:35","fltArrTime":"0:35","minPersons":"1","tktNum":"-1","endPersons":"-1","saleStartDate":"2012-12-10 00:00:00.0","status":"SALE_FINISHED","lostcabin":"0","saleEndDate":"2012-12-17 23:59:59.0"},{"id":"5868","price":"100.00","oprice":"2200.00","discount":"0.45","fltNum":"JD5196","fltDate":"2012-12-25","fltDepTime":"20:35","fltArrTime":"0:35","minPersons":"1","tktNum":"2","endPersons":"2","saleStartDate":"2012-12-11 00:00:00.0","status":"SALE_FINISHED","lostcabin":"0","saleEndDate":"2012-12-18 23:59:59.0"},{"id":"5875","price":"100.00","oprice":"2200.00","discount":"0.45","fltNum":"JD5196","fltDate":"2012-12-26","fltDepTime":"20:35","fltArrTime":"0:35","minPersons":"1","tktNum":"1","endPersons":"1","saleStartDate":"2012-12-12 00:00:00.0","status":"SALE_FINISHED","lostcabin":"0","saleEndDate":"2012-12-19 23:59:59.0"},{"id":"5880","price":"100.00","oprice":"2200.00","discount":"0.45","fltNum":"JD5196","fltDate":"2012-12-27","fltDepTime":"20:35","fltArrTime":"0:35","minPersons":"1","tktNum":"2","endPersons":"2","saleStartDate":"2012-12-13 00:00:00.0","status":"SALE_FINISHED","lostcabin":"0","saleEndDate":"2012-12-20 23:59:59.0"},{"id":"5895","price":"100.00","oprice":"2200.00","discount":"0.45","fltNum":"JD5196","fltDate":"2012-12-28","fltDepTime":"20:35","fltArrTime":"0:35","minPersons":"1","tktNum":"3","endPersons":"3","saleStartDate":"2012-12-12 00:00:00.0","status":"SALE_FINISHED","lostcabin":"0","saleEndDate":"2012-12-21 00:00:00.0"}]}';
    my $jsonobj = decode_json($routesStr);
    print Dumper($jsonobj);
}
