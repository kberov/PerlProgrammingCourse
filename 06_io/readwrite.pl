use strict; use warnings; $\ = $/;
my $FH;
my $file = 'test.txt';
if (open($FH,'<', $file) ) {
    local $/;    # slurp mode
    my $text = <$FH>;
    print "Content of $file:\n$text";
}
else {
    open($FH,'>', $file);#create it
    print $FH 'Hello!';
}
close $FH