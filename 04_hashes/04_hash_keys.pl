use strict;
use warnings;
#sorted by key
foreach my $key (sort(keys %ENV)) {
    print $key, ' => ', $ENV{$key}, "\n";
}