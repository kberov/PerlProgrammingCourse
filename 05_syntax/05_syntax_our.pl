use strict; use warnings; $\ =$/;
{
    package GoodDogs;
    print 'We are in package ' . __PACKAGE__;
    our $dog = 'Puffy';
    {
        print 'Our dog is named ' . $dog;
        my $dog = 'Betty';
        print 'My dog is named ' . $dog;
    }
    print 'My dog is named ' . $dog;

    package BadDogs;
    print $/.'We are in package ' . __PACKAGE__;
    print 'Previous dog is named ' . $dog;
    print 'Your dog is named ' . $GoodDogs::dog;
    our $dog = 'Bobby';
    print 'Our dog is named ' . $dog;
}