use strict;
use warnings;
use IO::Socket;
my ($host, $port, $path) = (
  'localhost',
  8088,

  #'bulgarian-creative-circle.org',
  #80,
  '/slides/13_net/io-socket-response.txt'
);

my $sock = IO::Socket::INET->new(
  PeerAddr => $host,
  PeerPort => $port,
  Proto    => 'tcp',
  Timeout  => 1
) or die $@;

#or just
#my $sock = IO::Socket::INET->new("$host:$port");
#$sock->autoflush; #like $| = 1 -- turned on by default

die "Could not connect to $host$/"
  unless $sock->connected;

if ($host !~ /localhost/) {

  # communicate with the server
  my $location = $host;
  $location .= ":$port" if $port != 80;
  print "Server says: ", print $sock->getline;

  #get default page
  $sock->print(
    join("\015\012",
      "GET $path HTTP/1.1",
      "Host:$location", "User-Agent:IO::Socket/$IO::Socket::VERSION ($^O)",
      "", "")
  );
  print $sock->getlines;

}
else {
  # communicate with the server
  print "Client connected.\n";
  print "Server says: ", $sock->getline;
  $sock->print("Hello from the client!\n");
  $sock->print("And goodbye!\n");

}
$sock->close or die $!;


