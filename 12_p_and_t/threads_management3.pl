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
my @threads = ();
while ($i<30){
    push @threads, threads->create(\&a_thread,[localtime]);
    push @threads, threads->new(\&a_thread,[localtime]);
    $i++;
}
#uncomment and run again
#print $_->join foreach @threads;

exit;
sub a_thread {
    my @params = @_;
    my $self = threads->self();
    my $thread_id = $self->tid();
    my $rv = '';
    if($thread_id %2){
        sleep $thread_id;
    }
    print 'thread with id '.$thread_id .$/;
    $rv .= sprintf(' Time is: %02d:%02d:%02d'.$/,
            $params[-1]->[2],$params[-1]->[1],$params[-1]->[0]);
    return $rv;
}