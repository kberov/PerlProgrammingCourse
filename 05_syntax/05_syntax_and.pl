use strict; use warnings; $\ = $/;$|++;
my ($me,$you) = qw(me you);
print 'We are here:'.($me && $you) if ($me && $you);
print 'We are here:'.($me and $you) if ($me and $you);
undef $me; 
print 'We are here:' if ($me and $you) or die 'Someone';