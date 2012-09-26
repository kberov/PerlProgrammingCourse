use strict; use warnings; $\ = $/;
open(FILE,'<','test.txt') 
    or die 'Can\'t open test.txt for reading. '.$!;
open(FILE,'>','test.txt') 
    or die 'Can\'t open test.txt for wriring. '.$!;
open(FILE,'>>','test.txt') 
    or die 'Can\'t open test.txt for appending. '.$!;
    