#$, = $\ =$/;
my @numbers = (1, 4.5, 15, 32 );
my @family  = ('me', 'you', 'us');
print '@family:', @family,$/;
$family[3]  = 'he';
print '@family:', @family,$/;
my @things  = (@numbers, @family);#flattened
printf @things;
print '-----------------';
my @predators = qw/leopard tiger panther/;
my @slices  = (1..3, A..D);
print $/;
print @numbers,@family,@things,@slices,@predators;