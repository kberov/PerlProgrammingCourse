#!/usr/bin/perl
# tcpinetclient.pl
use warnings;
use strict;
use Socket;
my $proto = getprotobyname('tcp');
my $host  = inet_aton('localhost');
my $port  = 8088;

# Create 'sockaddr_in' structure to connect to the given
# port on the IP address for the remote host
my $servaddr = sockaddr_in($port, $host);

# Create a socket for connecting on
socket SERVER, PF_INET, SOCK_STREAM, $proto
  or die "Unable to create socket: $!";

# bind the socket to the local port and address
connect SERVER, $servaddr or die "Unable to connect: $!";

# enable autoflush
select SERVER;
$| = 1;
select STDOUT;

# communicate with the server
print "Client connected.\n";
print "Server says: ", scalar(<SERVER>);
print SERVER "Hello from the client!\n";
print SERVER "And goodbye!\n";
close SERVER;

#Example script from "Professional Perl Programming/Chapter 23: Networking with Perl" by Wrox Press Ltd.

