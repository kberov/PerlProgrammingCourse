use strict; use warnings; $\ = $/;
use English;#use nice English names for ugly punctuation variables

{
    local $^O = 'Win32';
    local $OUTPUT_RECORD_SEPARATOR = "\n-----\n";#$\
    local $OUTPUT_FIELD_SEPARATOR = ': ';#$,
    print 'We run on', $OSNAME;
    
    open my $fh, $PROGRAM_NAME or die $OS_ERROR;#$0 $!
    local $INPUT_RECORD_SEPARATOR ; #$/ enable localized slurp mode
    my $content = <$fh>;
    close $fh;
    print $content;
    #my $^O = 'Solaris';#Can't use global $^O in "my"...
}
print 'We run on ', $OSNAME;