use strict;
use Test::More tests => 7;

# test context {{{
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
my $test_string = "week day Istiqlal, day Baha of month Baha, year one-hundred sixty of year Jad of the vahid Baha of the 1st kull-i-shay, holy day: Naw Ruz";
# }}}

BEGIN { use_ok('Date::Baha::i') };

# NOTE: The TZ functionality is not tested and epoch time conversion
# uses gmtime, due to local variation.

# as_string functionality
#
my $date = as_string ($test_date);
is $date, $test_string,
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
is $date, '7th day of the week, 1st day of the 1st month, year 160, 8th year of the 9th vahid of the 1st kull-i-shay, holy day: Naw Ruz',
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
is $date, '7th week day Istiqlal, 1st day Baha of the 1st month Baha, year one-hundred sixty (160), 8th year Jad of the 9th vahid Baha of the 1st kull-i-shay, holy day: Naw Ruz',
    'long alpha-numeric string';
$date = as_string ($test_date,
    size    => 0,
    numeric => 1,
    alpha   => 1,
);
is $date, 'Istiqlal (7), Baha (1) of Baha (1), year 160, Jad (8) of Baha (9)',
    'short alpha-numeric string';