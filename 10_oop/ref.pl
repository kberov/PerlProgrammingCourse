use strict; use warnings;use utf8; 
use Scalar::Util qw(blessed reftype);
$\=$/;
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

    sub type { __PACKAGE__ }
}
#our regular script start here
my $doggy = Dog->new();
print 'Hi again
We are in package: ' . __PACKAGE__
    .$/.'But we have yet another in the same file.'
    .$/.'We even made it a class called '.$doggy->type.'.';

print 'One proove'
    if ref $doggy eq 'Dog';

print 'Second proove'
    if $doggy->isa('Dog');
print 'Third proove:'. blessed $doggy
    if blessed $doggy; 
print 'Fourth proove:'. reftype $doggy
    if reftype $doggy; 
print 'Ops. I lied...'
if reftype $doggy eq 'HASH';  

    
    
    
