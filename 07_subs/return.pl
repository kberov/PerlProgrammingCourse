use strict; use warnings; use diagnostics; $\ = $/;
#prints favorite pet or a list of all pets
my @pets = qw|Goldy Amelia Jako|;
print run($ARGV[0]);
sub run {
    my $pref = shift||'';#favorite or list of pets
    if($pref) { favorite() }
    else      { local $,=$/; print pets() }
}
sub favorite {
    'favorite:'.$pets[1]
}
sub pets {
    return ('all pets:', @pets)
}