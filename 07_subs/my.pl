use strict; use warnings;
$\ = $, = $/;
my $dog = 'Puffy';
{
    my $dog = 'Betty';
    print 'My dog is named ' . $dog;
}
print 'My dog is named ' . $dog;
my ($fish, $cat, $parrot) = qw|Goldy Amelia Jako|;
print $fish, $cat, $parrot;
#print $lizard;
#Global symbol "$lizard" requires explicit package name...