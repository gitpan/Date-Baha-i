use strict;
use Test::More tests => 9;

BEGIN { use_ok('Date::Baha::i') };

# XXX This is one REALLY naive test suite.  :-(

my %date = date ();
is join (', ', sort keys %date),
    "cycle, cycle_name, cycle_year, day, day_name, dow, dow_name, kull_i_shay, month, month_name, timezone, year, year_name",
    "convert time to Baha'i date structure";

# Name lists.
my @ret = cycles ();
is @ret, 19, 'cycle list';
@ret = years ();
is @ret, 19, 'years list';
@ret = months ();
is @ret, 20, 'months list';
@ret = days ();
is @ret, 19, 'day list';
@ret = days_of_the_week ();
is @ret, 7, 'days of the week list';
my %ret = holy_days ();
is keys %ret, 13, 'holy day hash';

# Gregorian to Baha'i date
%date = greg_to_bahai (2003, 3, 5);
is keys %date, 13, "Gregorian to Baha'i date";
