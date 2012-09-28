#!/usr/bin/perl
BEGIN {
    use Config;
    $Config{useithreads} 
        or die('Threads support needed.');
}
use strict;use warnings;
use threads;
use threads::shared;
$|++;
my $i=0;
my $counter:shared = 0;
my @threads;
while ($i<6){

    threads->create(\&a_thread)->join ;
    threads->new(\&a_thread)->join ;
    $i++;
}

exit;
sub a_thread {

    my $self = threads->self();
    my $thread_id = $self->tid();
    lock($counter);
    print '/','*'x 20,$/;
    print 'thread with id: '.$thread_id .$/;
    if($thread_id %2){
        print 'changing $counter from '.$counter;
        sleep 2;
        $counter +=2;
        print ' to '.$counter,"($thread_id)",$/;
    }else{
        print 'changing $counter from '.$counter;
        sleep 1;
        $counter ++;
        print ' to '.$counter,"($thread_id)",$/;
    }

    print '*'x 20,'/'.$/;
}