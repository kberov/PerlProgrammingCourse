use strict; use warnings; $\ = $/;
use utf8;#comment this line
if ($^O =~/Win32/) {
    require Win32::Locale;
    binmode(STDOUT, ":encoding(cp866)")
        if(Win32::Locale::get_language() eq 'bg')
}
else{#assume some unix
    binmode(STDOUT, ':utf8') if $ENV{LANG} =~/UTF-8/;
}
my ($малки, $големи) = ("BOB\n", "боб$/");
print lc $малки, uc($големи) ;
print chomp($малки, $големи) ;
print length $малки,'|',length $големи ;
print $малки, $големи ;
