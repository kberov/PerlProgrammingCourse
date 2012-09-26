#length
use utf8;

print( length 'kniga' , $/);
use bytes;
print( length 'книга', $/);
no bytes;
print( length 'книга', $/);