use strict; use warnings; $\ = $/;
$|++;# enable $OUTPUT_AUTOFLUSH
my ($me,$you) = qw(me you);
print 'Somebody is here:'.($me || $you) if ($me || $you);
print 'Somebody is here:'.($me or $you) if ($me or $you);
($me,$you) = ('me', undef);#undef 'me' and try again
print 'Somebody is here:'.($me or $you)
    if ($me or $you) or die 'Nooo..';
($me,$you) = (undef, 'you');
print 'Somebody is here:'.($me or $you)
    if ($me or $you) or die 'no one';