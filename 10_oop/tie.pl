use strict;use warnings; use utf8;
use DB_File ; use Data::Dumper;
$\=$/;
#tie a hash to a berkely database 1.x
my (%table,$k,$v);
tie %table, "DB_File", "db_file.db", 
    O_RDWR|O_CREAT, 0644, $DB_HASH 
        or die "Cannot open file 'db_file.db': $!";

# Add a few key/value pairs to the file
$table{"apple"} = "red" unless exists $table{"apple"};
$table{"orange"} = "orange" unless exists $table{"orange"};
$table{"banana"} = "yellow" unless exists $table{"banana"};
$table{"tomato"} = "red" unless exists $table{"tomato"};

# Check for existence of a key
print "Banana Exists" if exists $table{"banana"} ;
# Delete a key/value pair.
delete $table{"apple"} ;
# dump the contents of the file

print Dumper(\%table);
untie %table;