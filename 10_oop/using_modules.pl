use strict; use warnings; use utf8;
use FindBin;
BEGIN {$ENV{APP_ROOT} = $FindBin::Bin .'/..'}
use lib($ENV{APP_ROOT}.'/lib');
use Data::Table;#patched... See TODO in module
use Data::Dumper;

binmode(STDOUT, ':utf8') if $ENV{LANG} =~/UTF-8/;
print '$ENV{APP_ROOT}:'.$ENV{APP_ROOT}."\n\n";
print '$FindBin::Bin:'.$FindBin::Bin."\n\n";

# Read a csv file into a table object
my $t = Data::Table::fromCSV(
            "$ENV{APP_ROOT}/data/products.csv"
            );

$t->addRow([
           'сирене',
           'Синьо 
           с маслини',
           0.500,0.30
           ]);
$t->tsv(1,{file=>\*STDOUT});
#or just
print $/.$t->tsv;
#print Dumper($t);

