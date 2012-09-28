use strict;use warnings;
use IO::Socket;
use POSIX qw(:sys_wait_h);
my ($host, $port, $path ) = ( 'localhost', 8088 );
my $server = new IO::Socket::INET (
    LocalAddr => $host,
    LocalPort => $port,
    Proto => 'tcp',
    Listen => 10,
    Type      => SOCK_STREAM,
    ReuseAddr => 1
) or die $@;


sub REAPER {
    1 until (-1 == waitpid(-1, WNOHANG));
    $SIG{CHLD} = \&REAPER;
}

$SIG{CHLD} = \&REAPER;

print "Server ($0) running on port $port...\n";
while (my $connection = $server->accept) {
    if (my $pid = fork){
        handle_connection($connection,$$);
    }
}
$server->close();
sub handle_connection {
    my $connection = shift;
    my $pid = shift||0;
    print "Client connected at ", scalar(localtime), "\n";
    $connection->print(
        'You\'re connected to the server!'
        .'This is process id '.$pid .$/
    );
    while (<$connection>) {
        print "Client says: $_";
    }
    $connection->shutdown(2);
    print "Client disconnected\n";
}

