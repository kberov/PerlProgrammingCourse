use strict;
use warnings;
use IO::Socket;
my $server = IO::Socket::UNIX->new(Peer => "./udssock",) or die $@;

# communicate with the server
print "Client connected.\n";
print "Server says: ", $server->getline;
$server->print("Hello from the client!\n");
$server->print("And goodbye!\n");
$server->close;


#Based on example from "Professional Perl Programming/Chapter 23: Networking with Perl" by Wrox Press Ltd.
