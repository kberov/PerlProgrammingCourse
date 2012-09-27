use strict; use warnings;
my $string ='stringify this world of 
words and anything';

my $word = 'string'; my $animal = 'dog';
print "found '$word'\n" if $string =~ /$word/;
print "it is not about ${animal}s\n" 
    if $string !~ /$animal/;
    
for('dog','string','dog'){
    print "$word\n" if /$word/
}