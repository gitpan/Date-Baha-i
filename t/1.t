use strict;
use Test::More tests => 11;

BEGIN { use_ok("Date::Baha::i") };

# XXX This is one REALLY naive test suite.  :-(

# Check the date output.
my %date = date ();
is join (', ', sort keys %date),
    "cycle, cycle_name, cycle_year, day, day_name, dow, dow_name, kull_i_shay, month, month_name, timezone, year, year_name",
    "Baha'i date in array context";
my $date = date (); 
ok length ($date) > 0, "Baha'i date in scalar context";

%date = greg_to_bahai (2003, 3, 5);
is keys %date, 13, "Gregorian to Baha'i date in array context";
$date = greg_to_bahai (2003, 3, 5);
ok length ($date) > 0, "Gregorian to Baha'i date in scalar context";

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
