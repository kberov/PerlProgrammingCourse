use strict; 
use warnings; $\ = $, = $/;
my $c = 1;
while (<DATA>){
    next unless /perl/;
    chomp and print "$c: $_";
    $c++;
}
__DATA__
This section of a perl file
can be used by the perl program
above in the same file to store 
and use some textual data
perl rocks!!!
Will the above line print if we remove this one?