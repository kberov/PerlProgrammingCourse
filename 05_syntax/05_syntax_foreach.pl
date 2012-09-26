use strict; use warnings; $\ = $, = $/;
my @pets = qw|Goldy Amelia Jako|;
my $favorite = 'Puffy';;
foreach $favorite(@pets) {
    print 'My favourite pet is:' . $favorite;
}
print '---',
     'My favourite pet is:' . $favorite,
      '---';
for $favorite(@pets) {
    print 'My favourite pet is:' . $favorite;
}
print '---',
     'My favourite pet is:' . $favorite,
     '---';
unshift @pets,$favorite;
for (@pets) {
    print 'My favourite pet is:' . $_;
}
print '---',
     'My favourite pet is:' . $favorite,
     '---';