use 5.005;
use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME' => 'Date::Baha::i',
    'VERSION_FROM' => 'i.pm',
    'PREREQ_PM' => {
        'Date::Calc' => 0,
        'Lingua::EN::Numbers::Ordinate' => 0,
        'Lingua::Num2Word' => 0,
    },
    ($] >= 5.005
        ? (ABSTRACT_FROM => 'i.pm',
           AUTHOR => 'Gene Boggs <cpan@ology.net>')
        : ()
    ),
);
