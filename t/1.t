use strict;
use Test::More tests => 8;

BEGIN { use_ok('Date::Baha::i') };

# XXX This is one naive test.  :-(
my %date = Date::Baha::i::date ();
is join (', ', sort keys %date),
    "cycle, cycle_name, cycle_year, day, day_name, dow, dow_name, kull_i_shay, month, month_name, timezone, year, year_name",
    "convert time to Baha'i date structure";

# Name lists.
my @ret = Date::Baha::i::cycles ();
is @ret, 19, 'cycle list';
@ret = Date::Baha::i::years ();
is @ret, 19, 'years list';
@ret = Date::Baha::i::months ();
is @ret, 20, 'months list';
@ret = Date::Baha::i::days ();
is @ret, 19, 'day list';
@ret = Date::Baha::i::days_of_the_week ();
is @ret, 7, 'days of the week list';
my %ret = Date::Baha::i::holy_days ();
is keys %ret, 13, 'holy day hash';
