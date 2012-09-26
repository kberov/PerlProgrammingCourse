use strict; use warnings; $\ = $/;
my $c = 0;
while ($c <= 10){
    print $c;
} 
continue {
    $c++;
    print $c - 1 . ' incremented by 1:';
};