use strict; use warnings;$|++;
warn 'Default variable is undefined' unless $_;
eval ' a syntax error or any failure';
if($@){
	warn 'You spoiled everything';
}

#...
use Carp qw(cluck croak confess);
other_place();

croak "We're outta here!";

sub here { 
    $ARGV[0] ||= 'try';
    if ($ARGV[0] =~ /try/){
        cluck "\nThis is how we got here!"
    } 
    elsif ($ARGV[0] =~ /die/){
        confess "\nNothing to live for!";
    } 
}
sub there { here; }
sub other_place { there }