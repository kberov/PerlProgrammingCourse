use strict; use warnings;
use File::Copy "cp";#alias for 'copy'
cp("file.txt","file2.txt") or die "Copy failed: $!";