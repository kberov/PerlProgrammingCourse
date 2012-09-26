use strict; use warnings; $\ = $/;
use Data::Dumper;
my $self = {
    name =>'Krassi',
    family_name => 'Berov',
    children =>[qw|Maria Pavel Viktoria|],
    fthings  => {
        color  => 'blue',
        animal => 'leopard',
        band   => 'Jethro Tull',
        languages => ['Bulgarian','French','English'],
    }
};
print "Hello! I am $self->{name} $self->{family_name}.\n"
    . 'I have '. scalar @{$self->{children}} . ' children. '
    . "They are named:\n\t" , (join  "\n\t", @{$self->{children}})
    . "\n\nI have also some favorite things:";
        
foreach (sort keys %{$self->{fthings}}) {
    if(ref $self->{fthings}{$_} eq 'HASH') {
        print "I Do not know how to output a HASH reference";
    }
    elsif(ref $self->{fthings}{$_} eq 'ARRAY') {
        print "\n", ucfirst($_), ":\n",
            map( "\t$_ \n", @{$self->{fthings}{$_}} );
            #Note: If the above line is confusing, why and why, if not?
    }
    else {
        print ucfirst($_).":\t" . $self->{fthings}{$_}; 
    }
}

my $ftings = $self->{fthings};
print $ftings;
$ftings->{doing_web} = 'yes';
#autovivify
push @{$ftings->{web_tools}}, 'Perl','XHTML','CSS','JavaScript';

print Data::Dumper->Dump([$self],['self']);

