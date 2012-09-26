#!/usr/bin/perl -C
#uc/lc
#binmode(STDOUT, ':encoding(cp866)');#on win32
use utf8;    
binmode(STDOUT, ':utf8');
my ($lcstr, $ucstr) = ("BOB\n", "боб$/");
print( lc $lcstr, uc($ucstr), $/ );