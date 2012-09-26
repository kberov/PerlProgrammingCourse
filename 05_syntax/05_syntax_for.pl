use strict; use warnings; $\ = $/;

for (my $i = 1; $i < 10; $i++) {
    print sprintf('%02d',$i);
}

#print sprintf('%02d',$i);
#Global symbol "$i" requires...

print '---';
my $i = 1;
while ($i < 10) {
    print sprintf('%02d',$i);
} continue {
    $i++;
}
print sprintf('%02d',$i);