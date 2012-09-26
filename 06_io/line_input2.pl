use strict; use warnings; 
#Segmentation fault if use 5.010;
$SIG{'INT'} = sub {print 'Oh you tried to kill me. '};

print  'Go on, enter something';
while (my $input = <STDIN>){
    chomp $input;
    print 'Go on, enter something' and next unless $input;
    print  sprintf( 'You wrote:"%s" and pressed "Enter"', $input);
    if($input =~ /\d+/){
        $input =~ s/[^\d]+//g;
        print sprintf('%d looks like number.', $input);
        print 'Enter some string';
    }else {
        printf $/
            .'"%s",Goood. now enter some number:', $input;
    } 
}