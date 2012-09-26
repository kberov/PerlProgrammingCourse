use strict; use warnings; $\ = $/; $|++;
#print "ARGUMENTS: @ARGV" and undef @ARGV  if @ARGV;
#Can't open.... 
print 'Tell me something';
my $line_input = <>;
if ($line_input eq $/){
    print 'You just pressed "Enter"'
}else {
    chomp $line_input;
    print 'You wrote:"' . $line_input 
        .'" and pressed "Enter".';
}
