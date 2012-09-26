use strict; use warnings;

sub hope;
sub syntax($) { 
    print "This is 'Subroutines' slide "
        .($_[0]||1) ."\n"; 
}
syntax $ARGV[0];
syntax();#Not enough arguments for...
hope;
hope();
&hope;
nope();
#nope;#Bareword "nope" not allowed...
sub hope { print "I hope you like Perl!\n"; }
sub nope { print "I am a dangerous Bareword.\n" }
my $code_ref = sub { print 'I am a closure'.$/ };
print $code_ref,$/;#CODE(0x817094c)
#$code_ref->() or 
&$code_ref;