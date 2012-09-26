use Data::Dumper;  
my %hash   = (me =>'you' );
my @array  = ('we',\%hash,['them']);
my $scalar = \@array;
print ref $scalar, $/;
print $scalar,$/;
print Dumper($scalar);