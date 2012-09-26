use strict;
use warnings;
$\ = $/;
my @numbers = (1, 4.5, 15, 32 );
my @family  = ('me', 'you', 'us');

print "Do $family[1] have $numbers[2] leva?";
print "Sorry, I do have $family[0] only.";
$"=', ';
print "O... @family... who cares!";