use 5.006;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Examle::Class',
    license             => 'Artistic_2_0',
    dist_author         => q{krasi <berov@cpan.org>},
    dist_version_from   => 'lib/Examle/Class.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    add_to_cleanup     => [ 'Examle-Class-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
