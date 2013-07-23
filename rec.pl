use Data::Dumper;
my $xxx = data_for_path(@ARGV);
dump_data_for_path('/etc', $xxx);
sub data_for_path {
  my $path = shift;
  if (-f $path or -l $path) {        # files or symbolic links
    return undef;
  }
  if (-d $path) {
    my %directory;
    opendir PATH, $path or die "Cannot opendir $path: $!";
    my @names = readdir PATH;
    closedir PATH;
    for my $name (@names) {
        next if $name eq '.' or $name eq '..';
        $directory{$name} = data_for_path("$path/$name");
    }
    return \%directory;
  }
  warn "$path is neither a file nor a directory\n";
  return undef;
}


sub dump_data_for_path {
        my $path = shift;
        my $data = shift;

        if (not defined $data) { # plain file
                print "$path\n";
                return;
        }

        my %directory = %$data;

        for (sort keys %directory) {
                dump_data_for_path("$path/$_", $directory{$_});
        }
}

