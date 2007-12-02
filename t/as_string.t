#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 7;

# test context
my $test_time = '1048204800';  # 2003/3/21 00:00:00
my %test_greg = (
    year  => 2003,
    month => 3,
    day   => 21
);
my $test_date = {
    cycle       => 9,
    cycle_name  => 'Baha',
    cycle_year  => 8,
    day         => 1,
    day_name    => 'Baha',
    dow         => 7,
    dow_name    => 'Istiqlal',
    holy_day    => { 'Naw Ruz' => [3, 21] },
    kull_i_shay => 1,
    month       => 1,
    month_name  => 'Baha',
    year        => 160,
    year_name   => 'Jad',
};

use_ok('Date::Baha::i');

# NOTE: The TZ functionality is not tested here and epoch time
# conversion uses gmtime, due to tester local variation.

my $date = as_string ($test_date);
is $date, "week day Istiqlal, day Baha of month Baha, year one sixty, Jad of the vahid Baha of the first kull-i-shay, holy day: Naw Ruz",
    'long alpha string';
$date = as_string ($test_date,
    size    => 0,
    numeric => 0,
    alpha   => 1,
);  
is $date, 'Istiqlal, Baha of Baha, Jad of Baha',
    'short alpha string';
$date = as_string ($test_date,
    size    => 1,
    numeric => 1,
    alpha   => 0,
);
is $date, 'seventh day of the week, first day of the first month, year 160, eighth year of the ninth vahid of the first kull-i-shay, holy day: Naw Ruz',
    'long numeric string';
$date = as_string ($test_date,
    size    => 0,
    numeric => 1,
    alpha   => 0,
);
is $date, '1/1/160', 'short numeric string';
$date = as_string ($test_date,
    size    => 1,
    numeric => 1,
    alpha   => 1,
);
is $date, 'seventh week day Istiqlal, first day Baha of the first month Baha, year one sixty (160), eighth year Jad of the ninth vahid Baha of the first kull-i-shay, holy day: Naw Ruz',
    'long alpha-numeric string';
$date = as_string ($test_date,
    size    => 0,
    numeric => 1,
    alpha   => 1,
);
is $date, 'Istiqlal (7), Baha (1) of Baha (1), year 160, Jad (8) of Baha (9)',
    'short alpha-numeric string';
