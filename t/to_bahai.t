#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 368;
use Date::Calc qw(Delta_Days Add_Delta_Days);

use_ok 'Date::Baha::i';

my %date = to_bahai (
    epoch => '1048204800',
    use_gmtime => 1,
);
delete $date{timezone};
is_deeply \%date, {
    cycle       => 9,
    cycle_name  => 'Baha',
    cycle_year  => 8,
    day         => 1,
    day_name    => 'Baha',
    dow         => 7,
    dow_name    => 'Istiqlal',
    holy_day    => 'Naw Ruz',
    kull_i_shay => 1,
    month       => 1,
    month_name  => 'Baha',
    year        => 160,
    year_name   => 'Jad',
}, '2003/3/21 00:00:00 epoch';

# Test one Baha'i year.
my @start = (2003, 3, 21);
my @stop  = (2004, 3, 20);

# The Baha'i (160) year starts on the 7th weekday.
my ($year, $month, $day, $dow) = (160, 1, 1, 7);
my ($max, $dow_max) = (19, 7);

for (0 .. Delta_Days (@start, @stop)) {
    # Increment our test sample date.
    my @date = Add_Delta_Days (@start, $_);

    my %date = to_bahai (
        year  => $date[0],
        month => $date[1],
        day   => $date[2],
    );
    is_deeply [ @date{qw(year month day dow)} ],
        [$year, $month, $day, $dow],
        join ('/', @date) . ' => ' .
        join ('/', @date{qw(year month day dow)});

    # Increment our test control date.
    $dow++;
    $dow = 1 if $dow > $dow_max;
    $day++;
    if ($day > $max) {
        $day = 1;
        $month++;
        $month = 1 if $month > $max;
    }
    # Hardcode for the 5 days of Ayyam-i-Ha.
    if ($month == 19 && $day == 1) {
        $month = -1;
    }
    if ($month == -1 && $day == 6) {
        $month = 19;
        $day = 1;
    }
}
