use strict;
use JSON;
require "dezhi.pl";

open(my $fh, ">", "./flights.txt");
my $ua = createua();
for (1..220) {
    my $flturl = "http://www.capitalairlines.com.cn/frontend/groupbuying/groupindex/groupindex!doIndexDetail.action?detailId=$_";
    my $res = $ua->get($flturl);
    my ($flt) = $res->content() =~ /temptitleId"\s*>([^<]*)</;
    my ($routesStr) = $res->content() =~ m/var\s*routesStr\s*=\s*"(.*)";\s*$/m;
    $routesStr =~ s/'/"/g;
    $routesStr =~ s/root/"root"/;
    my $jsonobj = decode_json($routesStr);
    print $fh "flight id $_: $flt, ";
    unless (@{ $jsonobj->{'root'} }) {
        print $fh "no flights\n\n";
        next;
    }
    print $fh "Current max date ${ $jsonobj->{'root'} }[-1]->{'fltDate'}, status: ${ $jsonobj->{'root'} }[-1]->{'status'}, price ${ $jsonobj->{'root'} }[-1]->{'price'} \n\n";
    sleep 1;
}
