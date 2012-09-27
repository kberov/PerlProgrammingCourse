use strict; use warnings;use utf8; $\=$/;
binmode(STDOUT, ':utf8') if $ENV{LANG} =~/UTF-8/;
#create a class/package
{
    package Dog;
    sub new {
        my $class = shift;
        my $self = {
            name =>'Puffy',
            nationality =>'bg_BG',
        };
        bless $self, $class;
    }
    
    sub name {
        return $_[0]->{name}
    }
    
    sub bark {
        my $self = shift;
        print "\tбау, бау..."
    }
}
#our regular script start here

print 'We are in package: ' . __PACKAGE__
    .$/.'But we have yet another in the same file.'
    .$/.'We even made it a class called "Dog".';

my $doggy = Dog->new();
print 'Does my new dog has a name?';
print 'Yes, it is ' , $doggy->name, '.'
    if $doggy->can('name');

print $/.'This is a Bulgarian dog.'
    if $doggy->{nationality} =~ /bg/i;

print 'And it barks in Bulgarian'
    if $doggy->can('bark');
print 'Voila:';
$doggy->bark;
    
    
    
    
    
    
    
