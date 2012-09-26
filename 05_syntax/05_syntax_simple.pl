use strict; 
use warnings; 
$\ = $/;
my $simple = 'A simple statement.';
print 1,$simple;
eval { print 2,$simple };
do { print 3,$simple };
do { 
    $_++;
    print 4,$simple ,' ',$_,'+2'
};