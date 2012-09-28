use threads;
use Thread::Queue;

my $DataQueue = Thread::Queue->new();
my $thr = threads->create(sub {
    while (my $DataElement = $DataQueue->dequeue()) {
        print("Popped $DataElement off the queue\n");
    }
});
my $r={h=>4};
$DataQueue->enqueue(12);
$DataQueue->enqueue("A", "B", "C");
sleep(3);
$DataQueue->enqueue('D',$r,undef);
$thr->join();