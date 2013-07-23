my @input = qw(Gilligan Skipper Professor Ginger Mary_Ann);
my @sorted_positions = sort { $input[$a] cmp $input[$b] } 0..$#input;
my @ranks;
@ranks[@sorted_positions] = (1..@sorted_positions);

for (0..$#ranks) {
      print "$input[$_] sorts into position $ranks[$_]\n";
}

