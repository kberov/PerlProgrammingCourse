#calc.pl
use strict; use warnings; $\ = $/;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
our %opts;
GetOptions (\%opts, 
            'action|do=s','params|p=s@','verbose','help|?' );

print Dumper(\%opts) if $opts{verbose};

pod2usage(2) if $opts{help} or not $opts{action} ;

if($opts{action} eq 'sum') {
    sum()
}
elsif ($opts{action} eq 'subtract') {
    subtract();    
}
else {
    print 'The action ' . $opts{action} 
    .' is not implemented.';
}

exit;

sub sum {
    my $sum = 0;
    for(@{$opts{params}}){
        s/[^\d]+//g;#sanitize input
        print 'adding ' . $_ . ' to '. $sum if $sum;
        $sum += $_;
        print 'Result: ' . $sum
            if $_ != $opts{params}->[0];
    }
}

sub subtract {
    my $result = shift @{$opts{params}};
    for(@{$opts{params}}){
        s/[^\d]+//g;#sanitize input
        print 'subtracting '.$_ . ' from '. $result if $result;
        $result -= $_;
        print 'Result: ' . $result 
            if $_ != $opts{params}->[0];
    }
}

__END__


=head1 NAME

calc.pl - Calculations in real time

=head1 SYNOPSIS

    write SYNOPSIS


=head1 OPTIONS

    calc.pl -do sum

=head1 TODO

=over

=item Implement at least one more action

=item Consult documentation L<Getopt::Long> and L<Pod::Usage> documentation

=item Write needed documentation for calc.pl

=back

=cut
