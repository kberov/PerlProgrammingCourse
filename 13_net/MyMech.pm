package MyMech;
use Data::Dumper;
use base qw(WWW::Mechanize);
use HTML::TreeBuilder;

#the root url
our $url    = 'http://www.gsmarena.com/';
our $Config = {

  DEBUG       => 1,
  agent_alias => 'Windows IE 6',
  onerror     => \&Carp::croak,
  onwarn      => \&Carp::carp(),
  cookie_jar  => {},
  autocheck   => 1,
  agent =>
    "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.0.3) Gecko/20060425 SUSE/1.5.0.3-7 Firefox/1.5.0.3",

  #urls to listViews of phones
  #1.go to listView for each brand
  phones_urls => {

    #'BENQ-SIEMENS' => $url . 'benq_siemens-phones-42.php',
    NOKIA => $url . 'nokia-phones-1.php',
    SIEMENS   => $url . 'siemens-phones-3.php',

    #MOTOROLA  => $url . 'motorola-phones-4.php',
    #ALCATEL   => $url . 'alcatel-phones-5.php',
    #PANASONIC => $url . 'panasonic-phones-6.php',
    SONY => $url . 'sony-phones-7.php',

    #BOSCH     => $url . 'bosch-phones-10.php',
    #SAGEM     => $url . 'sagem-phones-13.php',

    #SAMSUNG         => $url . 'samsung-phones-9.php',
    #'SONY ERICSSON' => $url . 'sony_ericsson-phones-19.php',
  },

  #each regex will collect an array of links to singleViwes
  #2. go to singleView for each model
  phones_url_regexes => {

    #'BENQ-SIEMENS'  => 'benq_siemens_',
    NOKIA   => 'nokia_\w+(_sport)?-\w+\.php',
    SIEMENS => 'siemens_\w+-\w+\.php',

    #MOTOROLA        => 'motorola_.*\d{3,}\.php',
    #ALCATEL         => 'alcatel_ot_\w+-\w+\.php',
    #PANASONIC       => 'panasonic_\w+-\w+\.php',
    SONY => 'sony_cmd_',

    #BOSCH           => 'bosch_com_\w+-\w+\.php',
    #SAGEM           => 'sagem_',
    #SAMSUNG         => 'samsung_\w+-\w+\.php',
    #'SONY ERICSSON' => 'sony_ericsson_\w+-\w+\.',
  },

  #select the main small image
  #3. download the image
};
our $phictionary = {    #;) PHONE DICTIONARY
  No         => 0,
  Yes        => 1,
  Polyphonic => 'Полифонични',
  channels   => 'канални ',
  colors     => 'цвята',
};
our $page = {};

#this will be assigned to $tx_phones


=item get_phone_images

saves the gif images urls on disk

=cut

sub get_phone_images {
  my $self   = shift;
  my @images = @_;
  my $filename;
  foreach my $i (@images) {

    #print "\t".$i->url().$/ ;
    $i->url_abs() =~ /\/([^\/]+\.gif)$/i;
    $filename = $1;
    next if ($filename =~ /spacer\.gif/);

    # print "\t".'filename: '.$1.$/;
    $page->{image} = $filename;
    unless (-e './img/' . $filename) {
      $self->get($i->url_abs(), ":content_file" => './img/' . $filename);
      print "\t" . 'fetched: ' . $filename . $/;
      sleep 1;
    }
    else {
      print "\t" . 'file : ' . $filename . ' exists, skipping...' . $/;
    }
  }    #endof @images loop

  return $self;
}

=item  parse_page_content

Gets the content of the page and parse it in to nice struct...
The structure corresponds to the table fields in tx_phones 
this struct will be then inserted into the database using SQL::Abstract.
Returns the struct.

=cut

sub parse_page_content {
  my $self = shift;
  %args = @_;

  # my $format =$args{format}||
  my $content = $self->content();
  my $root    = HTML::TreeBuilder->new_from_content($content);

  #$root->parse($content);
  $root->eof();    # done parsing for this tree
  my $temp_page = {};

  # here is the first place wheere we store data from the html
  # it is then searched and filtered so the values from it
  # can go to $page and $tx_phones
  $temp_page->{image} = $page->{image};
  my $tx_phones;

  foreach my $h1 ($root->find_by_tag_name('h1')) {
    $temp_page->{title} = $h1->as_trimmed_text;
    $h1->delete;
    sleep 1;
    print $temp_page->{title} . $/;
    last;
  }
  my ($th_key, $temp_key, $count) = ('', '', 0);
  foreach my $table ($root->find_by_tag_name('table')) {
    print 'table ' . $count;
    foreach my $th ($table->find_by_tag_name('th')) {
      $th_key = $th->as_trimmed_text if $th->attr('scope');
    }
    foreach my $td ($table->find_by_tag_name('td')) {

      #fillin a table with keys and values from td class tt1 and td class nfo
      if ($td->attr('class') eq 'ttl') {
        $temp_key = $td->as_trimmed_text;
        next;
      }
      if ($td->attr('class') eq 'nfo') {
        if ($temp_key =~ /\w/) {
          $temp_page->{$th_key}{$temp_key} = $td->as_trimmed_text;
        }
        else {
          $temp_page->{$th_key}{'_'} = $td->as_trimmed_text;

        }
        next;
      }

#print $td->as_trimmed_text.$/.'----------------'.$/.$td->as_HTML.$/.'----------------'.$/;
    }    #endof $td loop
    $count++;
  }    #endof $table
  if (ref $temp_page) {
    print Dumper($temp_page);

  }
  $root->dump if $Config->{DEBUG};    # print( ) a representation of the tree
  $root->delete;                      # erase this tree because we're done with it

  #returns the parsed page
  return $temp_page;
}

1;

