use strict;
use Test::More tests => 10;

# test context {{{
my %test_date = (
    year  => 2003,
    month => 3,
    day   => 21
);
# }}}

BEGIN { use_ok 'Date::Baha::i' };

# Next holy day functionality.
my $date = next_holy_day();
ok $date, 'next holy day with no date argument';
$date = next_holy_day(@test_date{qw(year month day)});
is $date, 'First Day of Ridvan 4/21', 'next holy day in scalar context';
my @date = next_holy_day(@test_date{qw(year month day)});
is_deeply \@date, ['First Day of Ridvan', '4/21'],
    'next holy day in array context';

# Name lists.
my @ret = cycles();
is @ret, 19, 'cycle list';
@ret = years();
is @ret, 19, 'years list';
@ret = months();
is @ret, 20, 'months list';
@ret = days();
is @ret, 19, 'day list';
@ret = days_of_the_week();
is @ret, 7, 'days of the week list';
my $ret = holy_days();
is keys %$ret, 14, 'holy day hash';
