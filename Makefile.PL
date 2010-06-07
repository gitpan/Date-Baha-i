use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Date::Baha::i',
    AUTHOR              => q{Gene Boggs <gene@cpan.org>},
    VERSION_FROM        => 'lib/Date/Baha/i.pm',
    ABSTRACT_FROM       => 'lib/Date/Baha/i.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Date-Baha-i-*' },
);
