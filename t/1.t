use strict;
use Test::More tests => 18;
use Data::Dumper;

# test context {{{
my $test_time = '1048204800';  # 2003/3/21 00:00:00
my @test_greg = (2003, 3, 21);
my $test_date = {
    'kull_i_shay' => 1,
    'month' => 1,
    'dow_name' => 'Istiqlal',
    'cycle_name' => 'Baha',
    'day_name' => 'Baha',
    'cycle_year' => 8,
    'month_name' => 'Baha',
    'dow' => 7,
    'day' => 1,
    'year_name' => 'Jad',
    'year' => 160,
    'cycle' => 9,
    'holy_day' => { 'Naw Ruz' => [3, 21] },
};
my $test_string = "week day Istiqlal, day Baha of month Baha, year one-hundred sixty of year Jad of the vahid Baha of the 1st kull-i-shay, holy day: Naw Ruz";
# }}}

BEGIN { use_ok("Date::Baha::i") };

# NOTE: The TZ functionality not tested due to local variation.

# Check the date output.
#
my %date = date (
    timestamp => $test_time,
    use_gmtime => 1,
);
delete $date{timezone};
is_deeply \%date, $test_date,
    "Baha'i date in array context";

%date = greg_to_bahai (
    @test_greg,
    use_gmtime => 1,
);
delete $date{timezone};
is_deeply \%date, $test_date,
    "Gregorian to Baha'i date in array context";

my $date = date (
    timestamp => $test_time,
    use_gmtime => 1,
);
is $date, $test_string, 
    "Baha'i date in scalar context";

$date = greg_to_bahai (
    @test_greg,
    use_gmtime => 1,
);
is $date, $test_string, 
    "Gregorian to Baha'i date in scalar context";

# as_string () functionality
#
$date = as_string (\%date);
is $date, $test_string,
    'long alpha string';
$date = as_string (\%date,
    size    => 0,
    numeric => 0,
    alpha   => 1,
);  
is $date, 'Istiqlal, Baha of Baha, Jad of Baha',
    'short alpha string';
$date = as_string (\%date,
    size    => 1,
    numeric => 1,
    alpha   => 0,
);
is $date, '7th day of the week, 1st day of the 1st month, year 160, 8th year of the 9th vahid of the 1st kull-i-shay, holy day: Naw Ruz',
    'long numeric string';
$date = as_string (\%date,
    size    => 0,
    numeric => 1,
    alpha   => 0,
);
is $date, '7, 1/1/160',
    'short numeric string';
$date = as_string (\%date,
    size    => 1,
    numeric => 1,
    alpha   => 1,
);
is $date, '7th week day Istiqlal, 1st day Baha of the 1st month Baha, year one-hundred sixty (160), 8th year Jad of the 9th vahid Baha of the 1st kull-i-shay, holy day: Naw Ruz',
    'long alpha-numeric string';
$date = as_string (\%date,
    size    => 0,
    numeric => 1,
    alpha   => 1,
);
is $date, 'Istiqlal (7), Baha (1) of Baha (1), year 160, Jad (8) of Baha (9)',
    'short alpha-numeric string';

# next holy day
#
$date = next_holy_day (@test_greg);
is_deeply $date, { Ridvan => [4, 21] },
    'next holy day';

# Name lists.
#
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
my $ret = holy_days ();
is keys %$ret, 12, 'holy day hash';
