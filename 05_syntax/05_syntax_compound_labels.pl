use strict; use warnings; $\ = $/;
print 'LABELS:';
A_LABEL: for my $m (1..10){
    ANOTHER: for my $s(0..10) {
        last A_LABEL if $m > 4;#comment and try it again
        last if $s > 4 and print '---';
        print sprintf('%1$02d.%2$02d',$m,$s) ;
    }

} 