package Calling;
use strict; use warnings; $\ = $/;
use subs qw(dump_stacktrace);
require 'caller.pl';
run(@ARGV);
sub run {
    print '"run" called';
    OtherPackage::second(shift);
}

sub OtherPackage::second {
    print '"second" called with arg:',
    (shift||'none');
    my @a = ThirdPackage::third(@_);
}

sub ThirdPackage::third {
    print '"third" called';
    dump_stacktrace 'This is the stack trace:';
}