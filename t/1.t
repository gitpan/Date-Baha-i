use Test::More tests => 2;
BEGIN { use_ok('Date::Baha::i') };
my $bahai_date = bahai_date (1046822865);
is join (', ', map { "$_=>$bahai_date->{$_}" } keys %$bahai_date),
    "kull_i_shay=>1, dow_name=>Fidal, month=>19, cycle_name=>Baha, day_name=>Jamal, cycle_year=>7, month_name=>'Ala, dow=>4, day=>3, year_name=>Abad, cycle=>9, year=>159",
    "convert time to Baha'i date";
