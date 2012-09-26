#Perl Scalars
use strict; use warnings;
my $animal = "camel";
my $answer = 22;
print "Me:    Hello $animal! How old are you?\n";
print "$animal: $answer.$/";
print '-'x 20, $/;
print 'Named reference: ',${animal},$/;
$Other::animal = 'llama';
print "From package 'Other': $Other::animal\n";
print 'Perl version: ',$], $/;