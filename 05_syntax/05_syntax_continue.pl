use strict; use warnings; $\ = $/;
my ($c,$reached_10) = (1,);
while ($c) {
    print '- ' x $c, $c;
} continue {
    last if ($c == 1 and $reached_10);
    $c-- if $reached_10;
    $c++ if $c < 10 and not $reached_10;
    $reached_10++ if $c == 10;
}
