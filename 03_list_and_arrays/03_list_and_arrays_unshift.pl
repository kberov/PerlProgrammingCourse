use strict;
use warnings;
use Data::Dumper; 
$\ =$/;
my @names = qw ( Цвети Бети Пешо );
print 'elements:', scalar @names;
print 'elements:', unshift(@names,qw/Део Иво/);
print Dumper \@names;