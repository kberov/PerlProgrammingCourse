#!/usr/bin/perl
use strict;
use warnings;
use MyMech;
use Data::Dumper;

#Config
$MyMech::Config->{DEBUG} = 0;
my $Config = $MyMech::Config;

#print Dumper($Config);
my $mech = MyMech->new(
  agent      => $Config->{agent},
  cookie_jar => $Config->{cookie_jar},
  autocheck  => $Config->{autocheck},
  onwarn     => $Config->{onwarn}
);

#$mech->agent_alias($Config->{agent_alias});

my $Parsed_Site = {};
print "OK.$/ Conection to $MyMech::url established" . $/
  if ($mech->get($MyMech::url));
sleep 1;

#go to listView for each brand
foreach (reverse sort keys %{$Config->{phones_urls}}) {
  print "OK.$/ we got $_ " . $/ if $mech->get($Config->{phones_urls}{$_});
  sleep 1;
  print $/;

  #get the lins for singleViews
  my @links;
  @links = @{$mech->links};
  foreach my $l (@links) {
    my $page_url = $l->url();
    if ($page_url =~ qr/$Config->{phones_url_regexes}{$_}/) {
      print 'Link: ' . $page_url . ' let us go there! ' . $/;
      sleep 1;
      print 'Hurray, there we are ' . $/ if $mech->get($l->url_abs());
      sleep 1;

      # print " Now we need the image, right?  ".$/;
      print 'What are the images on this page? ' . $/;
      my @images;
      @images = $mech->find_all_images(tag => 'img', url_regex => qr/gif$/i);

      #get the images
      $mech->get_phone_images(@images);

      #let us get the content of the page and parse it into nice struct...
      $Parsed_Site->{$page_url} = $mech->parse_page_content();

      # save individual dump to afile
      open PAGE, '>www.gsmarena.com/' . $page_url . '.dump'
        or die 'can not open file...' . $!;
      print PAGE Dumper($Parsed_Site->{$page_url});
      close PAGE;

    }    #endof phones_url_regexes
  }    #endof links loop
}    #endof phones_urls loop;

open SITE, '>www.gsmarena.com.dump';
print SITE Dumper($Parsed_Site);
close SITE;
