use strict;
use warnings;
while ( my ($key,$value) = each %ENV ) {
    print "$key => $value\n";
}