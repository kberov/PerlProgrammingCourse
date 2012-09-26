use strict; use warnings;
use IO::File;
my $file = 'test.txt';
my $fh = IO::File->new("< $file");
my @lines;
$fh->binmode;#see binmode in perlfunc
@lines = $fh->getlines;
print "Content of $file:\n";
print $_ foreach (@lines);
$fh->close;
#TODO: write a program that writes to a file using IO::File