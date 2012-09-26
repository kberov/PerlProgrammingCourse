use strict; use warnings;
my $FH;
my $file = 'test.txt';
if (open($FH,'<', $file) ) {
    my @lines = <$FH>;
    print "Content of $file:\n";
    print $_ foreach (@lines);
}else {
    print 'Creating '. $file.$/;
    open($FH,'>', $file);
    print $FH $_.':Hello!'.$/ for (1..4);
}
close $FH;