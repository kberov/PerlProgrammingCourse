use strict;
use warnings;
$\ =$/;
my @fields = qw ( id name position );
my $SQL = 'SELECT '
    . join(", ", @fields)
    . ' from empoyees';
print $SQL;
