use strict; 
use warnings; 
use Data::Dumper; 
$\ =$/;
my %f_colors = ('apple', 'red', 'banana', 'yellow');
my @f_colors = %f_colors;

defined $f_colors[0] 
    and print $f_colors[0] .' defined';

defined $f_colors{'apple'} and
    print ' and is '.$f_colors{'apple'};

print 'Opss..'.$f_colors[0].' is '.$f_colors{$f_colors[0]};

defined $f_colors{'pear'} 
    and print ' and is '. $f_colors{'pear'}
        or print ' wow ...'.Dumper(\%f_colors);
