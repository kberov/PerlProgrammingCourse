use strict; use warnings;
our $dog = 'Puffy';
{
    local $\ =$/;
    print 'A line-feed is appended.';
}

print 'No new line at the end. ';
print 'A line feed is appended.'.$/; #;)

tell_dogs();

sub tell_dogs {
    local $\ =$/;
    print 'Our dog is named ' . $dog;
    my $dog = 'Betty';
    print 'My dog is named ' . $dog;
}

print $dog;#Puffy
print "\n---\n";