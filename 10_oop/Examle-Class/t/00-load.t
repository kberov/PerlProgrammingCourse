#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Examle::Class' ) || print "Bail out!\n";
}

diag( "Testing Examle::Class $Examle::Class::VERSION, Perl $], $^X" );
