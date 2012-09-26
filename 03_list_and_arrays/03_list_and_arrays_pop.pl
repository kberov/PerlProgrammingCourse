use strict;
use warnings;
use Data::Dumper; $\ =$/;
my @names = qw ( Цвети Бети Пешо );
my $last_name = pop(@names);
print "popped = $last_name";
print Dumper \@names;