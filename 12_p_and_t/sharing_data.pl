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
    #uncomment
    #d=>{}
);
my @threads;
while ($i<6){
    sleep 1;
    push @threads, threads->create(\&a_thread,\%hash,[localtime]);
    push @threads, threads->new(\&a_thread,\%hash,[localtime]);
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
    $params[0]->{id} = $thread_id;
    if($thread_id %2){
        sleep 2;
        $params[0]->{apple}='red';
    }else{
        sleep 1;
        $params[0]->{apple}='yellow';
        #$params[0]->{d}={};
    }
    print '/','*'x 20,$/;
    print Dumper $params[0];
    print 'thread with id '.$thread_id .$/,
    sprintf(' Time is: %02d:%02d:%02d'.$/,
            $params[-1]->[2],$params[-1]->[1],$params[-1]->[0]);
    print '*'x 20,'/'.$/;
}