use threads;
use threads::shared;
my $a :shared = 4;
my $b :shared = 'foo';
my $thr1 = threads->create(sub {
    lock($a);
    sleep(2);
    lock($b);
    $a++;
    $b .= $a;
})->join ;
my $thr2 = threads->create(sub {
    lock($b);
    sleep(2);
    lock($a);
    $a++;
    $b .= $a;
})->join ;
print $thr1,$/,$thr2,$/;