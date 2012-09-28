use strict;
use warnings;
use IO::Socket;
my $file = "./udssock";
unlink $file;
my $server = IO::Socket::UNIX->new(
  Local  => $file,
  Type   => SOCK_STREAM,
  Listen => 5
) or die $@;

print "Server running on file $file...\n";
while (my $connection = $server->accept) {
  $connection->print("You're connected to the server!\n");
  while (<$connection>) {
    print "Client says: $_\n";
  }
  $connection->close;
}

#Based on example from "Professional Perl Programming/Chapter 23: Networking with Perl" by Wrox Press Ltd.
