use strict;
use Test::More tests => 2;
BEGIN { use_ok('Date::Baha::i') };
my $date = Date::Baha::i::date (1046822865);  # arbitrary time string.
is join (', ', map { "$_=>$date->{$_}" } sort keys %$date),
    "cycle=>9, cycle_name=>Baha, cycle_year=>7, day=>3, day_name=>Jamal, dow=>4, dow_name=>Fidal, kull_i_shay=>1, month=>19, month_name=>'Ala, year=>159, year_name=>Abad",
    "convert time to Baha'i date structure";
