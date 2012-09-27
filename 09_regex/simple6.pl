use strict; use warnings;$\=$/;
my $string ='A probably long chunk of text containing strings';
print 'matched "A"' if $string =~ /^A/;
print 'matched "strings"' if $string =~ /strings$/;
print 'matched "A", matched "strings" and something in between' 
if $string =~ /^A.*?strings$/;