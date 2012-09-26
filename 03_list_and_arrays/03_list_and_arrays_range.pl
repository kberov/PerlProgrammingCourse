#!/usr/bin/perl 
use utf8; use strict; use warnings;
use utf8;use strict;use warnings;
if( $^O =~ /Win32/ ){
    binmode(STDOUT, ':encoding(cp866)');
}
elsif( $ENV{LANG} =~ /UTF-8/ and $^O=~/linux/i ){
    binmode(STDOUT, ':utf8');
} 
$, = $\ = $/;

#Example starts here

my @nums = (0x410 .. 0x44f);
print chr($nums[$_]) foreach(0..14);
#print a slice
print @nums[0..14],$/;
#print a character map table from slice
print ' dec |  hex  | char', '-' x 19;
print map {
    $_.' | '
    . sprintf('0x%x',$_).' | '.chr($_)
    . "\n" . '-' x 19
} @nums[0..14];
