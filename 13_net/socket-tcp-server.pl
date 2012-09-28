use strict;
use warnings;
use Socket;
my ($host, $port, $proto) = ('localhost', 8088,);

$proto = getprotobyname('tcp');

# Create 'sockaddr_in' structure to listen to the given port
# on any locally available IP address
my $servaddr = sockaddr_in($port, INADDR_ANY);

# Create a socket for listening on
socket SERVER, PF_INET, SOCK_STREAM, $proto
  or die "Unable to create socket: $!";

# bind the socket to the local port and address
bind SERVER, $servaddr or die "Unable to bind: $!";

# listen to the socket to allow it to receive connection requests
# allow up to 10 requests to queue up at once.
listen SERVER, 10;

# now accept connections
print "Server running on port $port...\n";
while (accept CONNECTION, SERVER) {
  select CONNECTION;
  $| = 1;
  select STDOUT;
  print "Client connected at ", scalar(localtime), "\n";
  print CONNECTION "You're connected to the server!\n";
  while (<CONNECTION>) {
    print "Client says: $_\n";
  }
  close CONNECTION;
  print "Client disconnected\n";
}

#Example script from "Professional Perl Programming/Chapter 23: Networking with Perl" by Wrox Press Ltd.

