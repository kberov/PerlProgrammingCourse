#!/usr/bin/perl
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
my @chars = map(chr , @nums);
print @chars;

print '-' x 20;
my @names = qw(Цвети Пешо Иван);
my @mapped = map {$_ if $_ eq 'Пешо'} @names;
print @mapped;