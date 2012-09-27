use strict; use warnings;use utf8;
use DB_File ;use Data::Dumper;
$\=$/;

my (%table,$obj);
tie %table, "DB_File", "db_file.db", 
    O_RDWR, 0644, $DB_HASH 
        or die "Cannot open file 'db_file.db': $!";
$obj = tied(%table);
my $value;
$obj->get("banana",$value) ;
print 'Banana is:'.$value;
$obj->put('cow','milk');
print Dumper(\%table);

undef $obj;
untie %table;