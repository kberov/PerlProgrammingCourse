#!/usr/bin/env perl
use 5.10.0;
#or 5.12.0 etc...;
#or just
#use feature qw(say state);
use strict;
use warnings;
for(1..9){
	stateful($_,$_);
}
sub stateful{
  my $param = shift;
  state $once = shift;
  say 'we were given ', $param, 
    ', but we kept first time call param: '.$once;
}
