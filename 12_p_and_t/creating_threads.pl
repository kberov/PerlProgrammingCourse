#!/usr/bin/perl
BEGIN {
    use Config;
    $Config{useithreads} 
        or die('Threads support needed.');
}
use strict;use warnings;
use threads;
$|++;
while (1){
    sleep 1;
    my $thread_id = threads->self()->tid;
    threads->create(\&a_thread,$thread_id,[localtime]);
    #OR
    threads->new(\&a_thread,$thread_id,[localtime]);
    
}

sub a_thread {
    my @params = @_;
    my $self = threads->self();
    my $thread_id = $self->tid();
    my @created_threads;
    if ($thread_id % 2){
        sleep 1;
        print "\t";
        threads->create(\&a_thread,$thread_id,@params);
    }
    foreach(reverse 1 .. @params-2){
    print "\t$/thread " . $params[$_] . ' created ';
    }
    print('thread with id '.$thread_id);

    print sprintf(' Time is: %02d:%02d:%02d'.$/,
            $params[-1]->[2],$params[-1]->[1],$params[-1]->[0]);

}