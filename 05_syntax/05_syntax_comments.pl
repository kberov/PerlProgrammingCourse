use strict; use warnings; 
$\ = $/;
my $simple = 'A simple statement.#not a comment.';
print $simple;#this is a comment
$simple =~ s#a##ig;
print $simple;
$simple =~ s/#//ig;
print $simple;
=pod
I like to use POD for multiline comments
but it is much more than that.
=cut
print $0 . ' finished.';