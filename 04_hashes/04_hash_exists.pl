use strict;
use warnings;
my %f_colors = ('apple', 'red', 'banana', 'yellow');
my @f_colors = %f_colors;
exists $f_colors[0] and
    print $f_colors[0] .' exists';
exists $f_colors{'apple'} and
    print ' and is '.$f_colors{'apple'};
print 'Ops..'.$f_colors[0].' is '.$f_colors{$f_colors[0]};