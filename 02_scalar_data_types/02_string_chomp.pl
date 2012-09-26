#!/usr/bin/perl
#chomp
#binmode(STDOUT, ':encoding(cp866)');#on win32
use utf8;    
binmode(STDOUT, ':utf8');
my ($bob_latin, $bob_cyr) = ("bob\n", "боб$/");
print( $bob_latin, $bob_cyr, $/ );
print( chomp($bob_latin,$bob_cyr) , $/ );
print( $bob_latin, $bob_cyr, $/ );