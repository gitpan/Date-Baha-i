#!/usr/bin/perl
use strict;
use warnings;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME => 'Date::Baha::i',
    VERSION_FROM => 'lib/Date/Baha/i.pm',
    PREREQ_PM => {
        'Date::Calc' => 0,
        'Time::Zone' => 0,
        'Lingua::EN::Numbers' => 0,
        'Lingua::EN::Numbers::Ordinate' => 0,
        'Lingua::EN::Numbers::Years' => 0,
    },
    ($] >= 5.005
        ? (ABSTRACT_FROM => 'lib/Date/Baha/i.pm',
           AUTHOR => 'Gene Boggs <gene@cpan.org>')
        : ()
    ),
);
