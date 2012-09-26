use strict; use warnings; $\ = $/;
#prints favorite pet or a list of all pets depending on context
my @pets = qw|Goldy Amelia Jako|;
run();

sub run {
    if(defined $ARGV[0]) {
        $ARGV[0] =~ s/[^\d]+//g; #sanitize input
        $ARGV[0] ||= 1; #default to scalar context
        if($ARGV[0] == 1)    { 
            my $favorite = pets(); #scalar context 
        }
        elsif($ARGV[0] >= 2) { 
            my @pets = pets() #list context    
        }
    }
    else { 
        pets(); #void context 
    }
}

sub pets {
    local $,=$/ 
    print ('all pets:', @pets) if wantarray; #list context
    return if not defined wantarray; #void context
    print 'favorite:'.$pets[1] if not wantarray; #scalar context
}