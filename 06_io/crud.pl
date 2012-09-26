#crud.pl
use strict; use warnings; $\ = $/;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
our %opts;
our $data_file = '../data/products.csv';
our $actions = {
    'create' => \&create,
    'read'   => \&list,
    'delete' => \&remove,
    'update' => ''
};

GetOptions (\%opts, 
            'action|do=s',
            'record|r=s',
            ,'verbose','help|?' );

print Dumper(\%opts) if $opts{verbose};

pod2usage(2) if $opts{help} or not $opts{action} ;



(exists $actions->{$opts{action}} 
 and ref $actions->{$opts{action}} eq 'CODE')
    ? $actions->{$opts{action}}()
        : print 'The action "' . $opts{action} .'" is not implemented.';
exit;

#actions start here
sub create {
    unless($opts{record}){
        die 'Please provide record to insert.';
    }

    open(F,'>>',$data_file) or die 'File '.$data_file.'does not exists.' .$/;
    #append blindly as last row
    print F $opts{record};
    close F;
    #print Dumper($table);
}

sub list {
    open F,'<', $data_file or die 'File '.$data_file.'does not exists.' .$/;
    my @FILE =<F>;
    close F;
    print map {
        $_ =~ s|\,|\t|g;
        $_ =~ s|"||g;
        $_;
    } @FILE;

}


sub remove {

}

__END__


=head1 NAME

crud.pl Create, Read, Update Delete application

=head1 SYNOPSIS

    crud.pl -do read
    #or
    crud.pl -do create -r 'comma,separated,data,record'


=head1 TODO

=over

=item Implement at least one more action

=item Consult documentation L<Getopt::Long> and L<Pod::Usage> documentation

=item Write needed documentation for crud.pl

=back

=cut
