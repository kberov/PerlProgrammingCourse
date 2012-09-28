use strict;use warnings;
use threads;
use IO::Socket;
my ($host, $port, $path ) = ( 'localhost', 8088 );
my $listen = IO::Socket::INET->new(
    LocalAddr => $host,
    LocalPort => $port,
    Proto => 'tcp',
    Listen => 10,
    Type      => SOCK_STREAM,
    ReuseAddr => 1
);
print "Server ($0) running on port $port...\n";

while (my $socket = $listen->accept) {
    async(\&handle_connection, $socket)->detach;
}
sub handle_connection {
    my $connection = shift;
    print "Client connected at ", scalar(localtime), "\n";
    $connection->print(
        'You\'re connected to the server!'
        .'This is thread '.threads->self->tid .$/
    );
    while (<$connection>) {
        print "Client says: $_";
    }
}