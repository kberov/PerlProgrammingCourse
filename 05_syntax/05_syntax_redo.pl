use strict; use warnings; $\ = $, = $/;
my ($c, $redone) = (1,0);
while (<DATA>){
    chomp; print "$c: $_"; $c++;
    if (/perl/ and not $redone) {
        $redone++;
        redo;
    }
    elsif($_ =~ /perl/ and $redone) {
        $redone--;
        next;
    }
    
}
__DATA__
This section of a perl file
can be used by the perl program
above in the same file to store 
and use some textual data
perl rocks!!!
