use strict; use warnings; $\ = $/;

unless( open(FH,$0)){ 
    die 'I do not exist on disk!'. $^E 
}
else {
    local $\ = undef;#slurp mode
    my $c=1;
    print "$0: ", sprintf('%02d',$c++), " $_" while <FH>;
}
print $/.'---';
my $hashref = {me=>1,you=>2,he=>3};
exists $hashref->{she}
    and print 'she: '.$hashref->{she}
        or print 'she does not exists.'
            and print sort values %$hashref;
