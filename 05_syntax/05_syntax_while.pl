use strict; use warnings; $\ = $/;
$|++;# enable $OUTPUT_AUTOFLUSH
my @sufx = qw(th st nd rd th th th th th th th);
my ($i,$c) = (1,0);
while ($i<=10) {
    print "This is $i$sufx[$i] iteration";
    sleep 1;
    $i++;
}

do {
    print "The \$i became $i";
} while $i < 10;

$i = 10;
until ($i<1) {
    print "This is $i$sufx[$i] countdown";
    sleep 1;
    $i--;
}

do {
    print "\$i became $i";
    $i--
} until $i < 1;

print '- ' x $c, $c and $c++ while ($c<=10) ;