use strict;
use warnings;
use Data::Dumper; 
$\ =$/;
my @names = qw ( Цвети Бети Пешо );
my $last_name = shift(@names);
warn "shifted = $last_name";
print Dumper \@names;