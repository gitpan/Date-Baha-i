use 5.005;
use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'         => 'Date::Baha::i',
    'VERSION_FROM' => 'i.pm',
    'PREREQ_PM'    => {},
    ($] >= 5.005 ?
        (ABSTRACT_FROM => 'i.pm',
         AUTHOR        => 'Gene Boggs <cpan@ology.net>') : ()),
);
