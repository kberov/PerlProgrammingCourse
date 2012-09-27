use strict; use warnings;
use utf8; 
binmode(STDOUT, ':utf8') if $ENV{LANG} =~/UTF-8/;
$\=$/;
my $string ="contains\r\n Then we have some\t\ttabs.б";

print 'matched б(\x{431})' 
if $string =~ /\x{431}/;
print 'matched б' if $string =~/б/;
print 'matched \r\n' if $string =~/\r\n/;
print 'The string was:"' . $string.'"';


