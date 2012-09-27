use strict; use warnings;$\=$/;
my $digits ="here are some digits3434 and then678 ";

print 'found some letters followed by leters or digits":'.$1 .$2
if $digits =~/([a-z]{2,})(\w+)/;

print 'found three letter followed by  digits":'.$1 .$2
if $digits =~/([a-z]{3}(\d+))/;

print 'found up to four letters followed by  digits":'.$1  .$2
if $digits =~/([a-z]{1,4})(\d+)/;

#Greedy

print 'found as much as possible letters 
followed by  digits":'.$1  .$2
if $digits =~/([a-z]*)(\d+)/;
