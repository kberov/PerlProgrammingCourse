use strict; use warnings;
my $string ='Stringify this stringy world.';
my $word = 'string'; 
print "found '$word' in any case\n" 
   if $string =~ m{$word}i;
   
#metacharacters
#{ } [ ] ( ) ^ $ . | * + ? \
print "The string \n'$string'\n contains a DOT\n" 
    if $string =~ m|\.|;

