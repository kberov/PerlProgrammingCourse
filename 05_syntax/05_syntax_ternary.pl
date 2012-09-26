use strict;use warnings; $\ = $/;
sub false{ 1>2 }
sub true { 1<2 }
sub true_false { return true() ? '1<2' : false() }
print true_false();

print 1 < 2 ?  'true' : 'false';