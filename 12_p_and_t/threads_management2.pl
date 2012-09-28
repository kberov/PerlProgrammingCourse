#!/usr/bin/perl
BEGIN {
    use Config;
    $Config{useithreads} 
        or die('Threads support needed.');
}
use strict;use warnings;
use threads;
$|++;
my $i=0;
while ($i<30){
    sleep 1;
    my $odd = threads->create(\&a_thread,[localtime]);
    $odd->detach;
    my $even = threads->new(\&a_thread,[localtime]);
    $even->detach;
    $i++;
}
exit;
sub a_thread {
    my @params = @_;
    my $self = threads->self();
    my $thread_id = $self->tid();
    my $rv = '';
    if($thread_id %2){
        sleep $thread_id;
    }
    $rv .= 'thread with id '.$thread_id ;
    $rv .= sprintf(' Time is: %02d:%02d:%02d'.$/,
            $params[-1]->[2],$params[-1]->[1],$params[-1]->[0]);
    print $rv;
}