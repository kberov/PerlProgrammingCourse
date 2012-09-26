use strict; use warnings; $\ = $/;
use Config;
print 'Do my perl uses old threads?';
print 'No' if !$Config{use5005threads};
print 'I do not have extras' if !$Config{extras};
print 'I do not have mail' if not $Config{mail};
