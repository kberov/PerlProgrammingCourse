#!/usr/bin/perl -C
#chop
#binmode(STDOUT, ':encoding(cp866)');#on win32
use utf8;    
binmode(STDOUT, ':utf8');

my ($bob_latin, $bob_cyr) = ('bob', 'боб');
print( chop($bob_latin) , $/, chop($bob_cyr) , $/);