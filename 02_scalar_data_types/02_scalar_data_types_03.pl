#Perl Hashes
my %fruit_colors = (
    apple  => "red",
    banana => "yellow",
);
print 
    map { "$_ => $fruit_colors{$_}\n" } 
        sort
            keys %fruit_colors;
print "%fruit_colors\n"; #hashes can NOT be interpolated