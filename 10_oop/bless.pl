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
            language =>'Bulgarian',
        };
        bless $self, $class;
    }
    sub language {
        $_[0]->{language} = $_[1] if $_[1];
    	return $_[0]->{language};
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


my $doggy = Dog->new();
print 'We are in package: ' . __PACKAGE__
    .$/.'But we have yet another in the same file.'
    .$/.'We even made it a class called "'.ref($doggy).'".';

print 'Does my new '.ref($doggy).' has a name?';
print 'Yes, it is ' , $doggy->name, '.'
    if $doggy->can('name');

print $/.'This is a '.$doggy->language.' barking '.ref($doggy).'.'
    if $doggy->{nationality} =~ /bg/i;

print 'And it barks in Bulgarian'
    if $doggy->can('bark');
print 'Voila:';
$doggy->bark;
    
    
    
    
    
    
    
