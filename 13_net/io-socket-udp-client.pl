use strict;
use warnings;
use IO::Socket;
my $host   = 'localhost';
my $port   = 4444;
my $client = new IO::Socket::INET(
  PeerAddr => $host,
  PeerPort => $port,
  Timeout  => 2,
  Proto    => 'udp',
);
$client->send("Hello from client") or die "Send: $!\n";
my $message;
$client->recv($message, 1024, 0);
print "Response was: $message\n";


#Based on example from "Professional Perl Programming/Chapter 23: Networking with Perl" by Wrox Press Ltd.
