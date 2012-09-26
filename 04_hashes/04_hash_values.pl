use strict;
use warnings;
#sorted by value
foreach my $value (sort(values %ENV)) {
    print $value, "\n";
}