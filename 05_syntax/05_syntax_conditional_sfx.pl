use strict; use warnings; $\ = $/;
{
    my $c=1;
    local $\ = undef;
    do {
            print "$0: ", sprintf('%02d',$c++), " $_"
            while <FH>
        } if open(FH,$0) or die 'I do not exist on disk!'. $^E;
}
print $/.'---'; 
my $hashref = {me=>1,you=>2,he=>3};
print 'she:'.$hashref->{she} if ( exists $hashref->{she} );
do {
    print 'she does not exists.';
    print sort values %$hashref;
} unless exists $hashref->{she};
###