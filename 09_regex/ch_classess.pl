use strict; use warnings;$\=$/;
my $string ='A probably long chunk of text containing strings';
my $thing  = 'ong ung ang enanything';
my $every  = 'iiiiii';
my $nums   = 'I have 4325 Euro';
my $class  = 'dog'; 
print 'matched any of a, b or c' 
if $string =~ /[abc]/;
print $/,$/;
for($thing, $every, $string){
    print 'ingy brrrings nothing using: '
    .$_
        if /[$class]/
}

print $/,$/;
print $nums if $nums =~/[0-9]/;

