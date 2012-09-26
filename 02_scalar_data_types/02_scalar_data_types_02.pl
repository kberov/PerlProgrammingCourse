my @animals = ("camel", "llama", "пиле");
my @numbers = (23, 42, 69);
my @mixed   = ("camel", 42, 1.23);
print @animals .$/;#what the...;) scalar context
print "@animals" . $/;#interpolated array
print "@animals @numbers" . $/;#interpolated arrays
print @animals, @numbers,  $/;#list context