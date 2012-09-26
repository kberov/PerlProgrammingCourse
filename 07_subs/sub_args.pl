use strict; use warnings; $\ = $/;
sub modify($) { 
    print "The alias holding "
        .($_[0]++) ." will be modifyed\n"; 
}

modify($ARGV[0]);
print $ARGV[0];

copy_arg($ARGV[0]);
print $ARGV[0];

sub copy_arg {
    my ($copy) = @_;
    print "The copy holding "
        .($copy++) ." will NOT modify \$ARGV[0]\n"; 
}