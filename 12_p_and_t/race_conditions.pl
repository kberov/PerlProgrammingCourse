#!/usr/bin/perl
BEGIN {
    use Config;
    $Config{useithreads} 
        or die('Threads support needed.');
}
use strict;use warnings;
use threads;
use threads::shared;
use Data::Dumper;
$|++;
my $i=0;
my %hash:shared = (apple=>'green',lemon=>'yellow',
    counter=>0
);
my @threads;
while ($i<6){
    sleep 1;
    push @threads, threads->create(\&a_thread,\%hash);
    push @threads, threads->new(\&a_thread,\%hash);
    $i++;
}
$_->join foreach @threads;
print Dumper \%hash;
exit;
sub a_thread {
    my @params = @_;
    my $self = threads->self();
    my $thread_id = $self->tid();
    my $rv = '';
    print '/','*'x 20,$/;    
    $params[0]->{id} = $thread_id;
    if($thread_id %2){
        my $j= threads->new(\&a_thread,$params[0]);
        $j->detach;
        #sleep 2;
        print $params[0]->{counter},$/;
        $params[0]->{counter} ++;
        print $params[0]->{counter},$/;
    }else{
        #sleep 1;
        $params[0]->{apple}='yellow';
        print $params[0]->{counter},$/;
        $params[0]->{counter} +=2;
        print $params[0]->{counter},$/;
    }

    print Dumper $params[0];
    print 'thread with id '.$thread_id .$/;
    print '*'x 20,'/'.$/;
}