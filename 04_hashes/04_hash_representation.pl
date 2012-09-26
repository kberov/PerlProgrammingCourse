use strict;
use warnings;
use Data::Dumper; $\ =$/;
my %fruit_colors = ('apple', 'red', 'banana', 'yellow');
print Dumper(\%fruit_colors);
my @fruit_colors = %fruit_colors;
print Dumper(\@fruit_colors);
%fruit_colors = @fruit_colors;
$fruit_colors{pear} = 'yellow';#add a key/value pair
print Dumper(\%fruit_colors);