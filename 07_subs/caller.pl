use strict; use warnings; $\ = $/;
use Data::Dumper;
sub dump_stacktrace {
    print shift || 'Dumping stacktrace:';
    my $call_frame = 1;
    local $,=$/;
    my %i;
    while(($i{package}, $i{filename}, $i{line},
           $i{subroutine}, $i{hasargs}, $i{wantarray},
           $i{evaltext}, $i{is_require}, $i{hints},
           $i{bitmask}, $i{hinthash})
           = caller($call_frame++)){
        print Data::Dumper->Dump(
            [\%i],['call '.($call_frame-1)]
        );
    }
}
