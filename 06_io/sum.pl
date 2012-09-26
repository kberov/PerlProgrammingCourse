use strict; use warnings; $\ = $/;
my $sum = 0;
for(@ARGV){
    s/[\D]+//g; #sanitize input
    $_ ||= 0;   #be sure we have a number
	print 'adding '.$_ . ' to '. $sum if $sum;
    $sum += $_;
    print 'Result: ' . $sum if $_ != $ARGV[0]
}
