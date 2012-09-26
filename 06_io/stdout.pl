#try it like this: perl stdout.pl > file.txt
#try it like this: perl stdout.pl 2> errors.txt
#try it like this: perl stdout.pl > file.txt 2> errors.txt

use strict; use warnings; $\ = $/; $|++;
$SIG{'INT'} = sub {warn 'Oh you tried to kill me. '};
#avoid "Can't open blbla: No such file or.."
print "ARGUMENTS: @ARGV" and undef @ARGV  if @ARGV;

print STDERR 'Go on, enter something';
while (my $input = <STDIN>){
    chomp $input;
    print STDERR 'Go on, enter something' and next unless $input;
    printf STDOUT ( 'You wrote:"%s" and pressed "Enter"'.$/, $input);
    if($input =~ /\d+/){
        $input =~ s/[^\d]+//g;
        print STDOUT sprintf('%d looks like number.', $input);
        print STDERR 'Enter some string';
    }else {
        printf STDOUT $/
            .'"%s",Goood.', $input;
        print STDERR 'Now enter some number:'
    } 
}