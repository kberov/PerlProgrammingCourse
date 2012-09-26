use Data::Dumper; 
$\ =$/;
my @family = qw ( me you us );
print scalar @family;#get the number of elements
print push(@family, qw ( him her ));
print Dumper \@family;
