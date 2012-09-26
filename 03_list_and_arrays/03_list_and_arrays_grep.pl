#!/usr/bin/perl -C
use utf8;use strict;use warnings;
if( $^O =~ /Win32/ ){
    binmode(STDOUT, ':encoding(cp866)');
}
elsif( $ENV{LANG} =~ /UTF-8/ and $^O=~/linux/i ){
    binmode(STDOUT, ':utf8');
} 
$, = ' ', $\ = $/;

#Example starts here
my @nums = (0x410 .. 0x44f);
my @chars = grep( 
            ($_ >= 0x410 and $_ < 0x430), @nums
            );
map($_ = chr, @chars);#modify inplace $_
print @chars;

#grep for 'а'
if( my $times = grep { chr($_) =~ /а/i } @nums ){
    print "'а' codes found:
 $times times in the list."
}
