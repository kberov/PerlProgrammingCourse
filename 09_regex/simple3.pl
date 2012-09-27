use strict; use warnings;
my $string ='Stringify this world!';
my $word = 'string'; my $animal = 'dog';
print "found '$word'\n" if $string =~ m#$word#;
print "found '$word' in any case\n" 
if $string =~ m{$word}i;
print "it is not about ${animal}s\n" 
    if $string !~ m($animal);
for('dog','string','Dog'){
    local $\=$/;
    print  if m|$animal|
}