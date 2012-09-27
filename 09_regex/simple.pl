use strict; use warnings;
my $string ='A probably long chunk of text containing strings';
print "found 'string'\n" if $string =~ /string/;
print "it is not about dogs\n" if $string !~ /dog/;

my $word = 'string'; my $animal = 'dog';
print "found '$word'\n" if $string =~ /$word/;
print "it is not about ${animal}s\n" 
    if $string !~ /$animal/;
    
for('dog','string','dog'){
    print "$word\n" if /$word/
}