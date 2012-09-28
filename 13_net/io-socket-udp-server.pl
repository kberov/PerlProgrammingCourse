#!/usr/bin/perl
use warnings;
use strict;
use IO::Socket;
my $port   = 4444;
my $server = new IO::Socket::INET(
  LocalPort => $port,
  Proto     => 'udp',
);
die "Bind failed: $!\n" unless $server;
print "Server running on port $port...\n";
my $message;

while (my $client = $server->recv($message, 1024, 0)) {
  my ($port, $ip) = unpack_sockaddr_in($client);
  my $host = gethostbyaddr($ip, AF_INET);
  print "Client $host:$port sent '$message' at ", scalar(localtime), "\n";
  $server->send("Message '$message' received", 0, $client);
}

#Based on example from "Professional Perl Programming/Chapter 23: Networking with Perl" by Wrox Press Ltd.
