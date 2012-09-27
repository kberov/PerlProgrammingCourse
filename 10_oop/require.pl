use strict; use warnings;use utf8;
;$\=$/;
if ($]>5.0095){
    require Time::Piece;
    my $t = Time::Piece->new();
    print 'Using Time::Piece...';
    print "Today:".$t->dmy('-');
}
else {
    require POSIX;
    print 'Using POSIX...';
    print "Today:".POSIX::strftime(
                   '%d-%m-%Y',localtime(time)
                   );
}