use strict; use warnings;use utf8;
use 5.010;
$\=$/;

use Time::Piece;
my $t = localtime;
say "Today:".$t->dmy('-');
