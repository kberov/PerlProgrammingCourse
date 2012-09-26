$\=$/; #$OUTPUT_RECORD_SEPARATOR is set to "\n"
$,=$/; #$OUTPUT_FIELD_SEPARATOR is set to "\n"
print qw (me you us);
print ('me', 'you', 'us');# the same as above
$me = qw (me you us);
print $me;                # prints 'us'