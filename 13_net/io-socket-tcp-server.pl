use strict;
use warnings;
use IO::Socket;
my ($host, $port, $path) = ('localhost', 8088);
my $server = new IO::Socket::INET(
  LocalAddr => $host,
  LocalPort => $port,
  Proto     => 'tcp',
  Listen    => 10,
  Type      => SOCK_STREAM,
  ReuseAddr => 1
);
print "Server ($0) running on port $port...\n";

while (my $connection = $server->accept) {
  print "Client connected at ", scalar(localtime), "\n";
  $connection->print("You're connected to the server!\n");
  while (<$connection>) {
    print "Client says: $_";
  }

  $connection->shutdown(2);
  print "Client disconnected\n";
}

$server->close();
