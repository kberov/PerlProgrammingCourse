use strict; use warnings;$\=$/;
my $digits ="here are some digits3434 and then678 ";

print 'found a letter followed by leters or digits":'.$1 
    if $digits =~/[a-z]([a-z]|\d+)/;
print 'found a letter followed by  digits":'.$1 
    if $digits =~/([a-z](\d+))/;
print 'found letters followed by  digits":'.$1 
    if $digits =~/([a-z]+(\d+))/;