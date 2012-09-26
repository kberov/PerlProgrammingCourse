use strict; use warnings;
my $dirname = 'samples';
my @files;
if(opendir(DIR,$dirname)){
	@files = readdir DIR;
    closedir DIR;
}
else {
    mkdir($dirname,0755) or die $!;
    for (1..20) {
        my $filename = "sample$_.txt";
        open(OUT,'>',$dirname.'/'.$filename) 
            and print OUT "hello from $filename";
        close OUT;
    }
    #now we can try to read again
    opendir(DIR,$dirname) or die $!;
    @files = readdir DIR;
    closedir DIR;
}

foreach (@files){
    next if /^\./;
    open(my $IN,'<',$dirname.'/'.$_) or die $!;
    read($IN, my $text, -s $dirname.'/'.$_) 
    or die 'Could not read '.$dirname.'/'.$_. $!;#wow!
    print $text.$/;
    close $IN;
}

# TODO:implement the same program using IO::Dir.