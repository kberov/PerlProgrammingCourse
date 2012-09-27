use strict; use warnings;$\=$/;
my $digits ="here are some digits3434 and then ";
print 'found digit' if $digits =~/\d/;
print 'found alphanumeric' if $digits =~/\w/;
print 'found space' if $digits =~/\s/;
print 'digit followed by space, followed by letter'
   if $digits =~/\d\s[A-z]/;