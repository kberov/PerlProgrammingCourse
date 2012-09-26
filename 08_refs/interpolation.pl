use strict; use warnings; $\ = $/;
my @pets = qw|Goldy Amelia Jako|;
my $self = {
    name =>'Krassi',
    family_name => 'Berov',
    can => sub { return shift },
    pets => \@pets,
    children =>[qw|Maria Pavel Victoria|],
};

print <<TXT;
 Hello! 
     I am $self->{name} $self->{family_name}.
     I can ${\$self->{can}('talk')}.
     My first child is $self->{children}[0].
     My last child is $self->{children}[-1].
     I do not have a pet named $self->{pets}[1].
TXT

