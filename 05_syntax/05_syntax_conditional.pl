use strict; use warnings; $\ = $/;
unless( open(FH,$0)){
    die 'I do not exist on disk!'. $^E
}
else {
    local $\ ;
    my $c=1;
    print "$0: ", sprintf('%02d',$c++), " $_" while <FH>;
}
print $/.'---'; #$,=$/;
my $hashref = {me=>1,you=>2,he=>3};

if ( exists $hashref->{she} ) {
    print 'she:'.$hashref->{she};
}
else {
    print 'she does not exists.';
    print sort values %$hashref;
}
###