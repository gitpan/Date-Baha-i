package Date::Baha::i;

# Package declarations {{{
use strict;
use vars qw($VERSION); $VERSION = '0.12.2';
use base qw(Exporter);
use vars qw(@EXPORT @EXPORT_OK);
@EXPORT = @EXPORT_OK = qw(
    as_string
    cycles
    date
    days
    days_of_the_week
    from_bahai
    holy_days
    months
    next_holy_day
    to_bahai
    years
);

use Date::Calc qw(
    Add_Delta_Days
    Date_to_Days
    Day_of_Week
    Timezone
    leap_year
);
use Lingua::EN::Numbers::Ordinate;
use Lingua::Num2Word;
# }}}

# Set constants {{{
use constant FACTOR => 19;
use constant FEBRUARY => 2;
use constant MARCH => 3;
use constant SHARAF => 16;
use constant LAST_START_DAY => 2;   # First day of the fast.
use constant YEAR_START_DAY => 21;  # Spring equinox.
use constant LEAP_START_DAY => 26;  # The intercalary days.
use constant FIRST_YEAR  => 1844;
use constant ADJUST_YEAR => 1900;
use constant CYCLE_YEAR => qw(
    Alif
    Ba
    Ab
    Dal
    Bab
    Vav
    Abad
    Jad
    Baha
    Hubb
    Bahhaj
    Javab
    Ahad
    Vahhab
    Vidad
    Badi
    Bahi
    Abha
    Vahid
);

use constant MONTH_DAY => qw(
    Baha
    Jalal
    Jamal
    'Azamat
    Nur
    Rahmat
    Kalimat
    Kamal
    Asma'
    'Izzat
    Mashiyyat
    'Ilm
    Qudrat
    Qawl
    Masa'il
    Sharaf
    Sultan
    Mulk
    'Ala
    Ayyam-i-Ha
);

# NOTE: Trailing 0's are stripped, resulting in incorrect
# computations if certain decimals are not quoted.
#   Month name   => [Number, Start, End],  # Non-leap year day span
use constant MONTHS => {
    "Baha"       => [ 0,  '3.21',  '4.08'],  # 80,  98
    "Jalal"      => [ 1,  '4.09',  '4.27'],  # 99, 117
    "Jamal"      => [ 2,  '4.28',  '5.16'],  #118, 136
    "'Azamat"    => [ 3,  '5.17',  '6.04'],  #137, 155
    "Nur"        => [ 4,  '6.05',  '6.23'],  #156, 174
    "Rahmat"     => [ 5,  '6.24',  '7.12'],  #175, 193
    "Kalimat"    => [ 6,  '7.13',  '7.31'],  #194, 212
    "Kamal"      => [ 7,  '8.01',  '8.19'],  #213, 231
    "Asma'"      => [ 8,  '8.20',  '9.07'],  #232, 250
    "'Izzat"     => [ 9,  '9.08',  '9.26'],  #251, 269
    "Mashiyyat"  => [10,  '9.27', '10.15'],  #270, 288
    "'Ilm"       => [11, '10.16', '11.03'],  #289, 307
    "Qudrat"     => [12, '11.04', '11.22'],  #308, 326
    "Qawl"       => [13, '11.23', '12.11'],  #327, 345
    "Masa'il"    => [14, '12.12', '12.30'],  #346, 364
    "Sharaf"     => [15, '12.31',  '1.18'],  #365,  18
    "Sultan"     => [16,  '1.19',  '2.06'],  # 19,  37
    "Mulk"       => [17,  '2.07',  '2.25'],  # 38,  56
    "Ayyam-i-Ha" => [-1,  '2.26',  '3.01'],  # 57,  60
    "'Ala"       => [18,  '3.02',  '3.20'],  # 61,  79
};

use constant DOW_NAME => qw(
    Jalal
    Jamal
    Kaml
    Fidal
    'Idal
    Istijlal
    Istiqlal
);
use constant HOLY_DAYS => {
    # Work suspended:
    "Naw Ruz"                   => [ 3, 21],
    "First Day of Ridvan"       => [ 4, 21],
    "Ninth Day of Ridvan"       => [ 4, 29],
    "Twelfth Day of Ridvan"     => [ 5,  2],
    "Declaration of the Bab"    => [ 5, 23],
    "Ascension of Baha'u'llah"  => [ 5, 29],
    "Martyrdom of the Bab"      => [ 7,  9],
    "Birth of the Bab"          => [10, 20],
    "Birth of Baha'u'llah"      => [11, 12],
    # Work not suspended:
    "Day of the Covenant"       => [11, 26],
    "Ascension of 'Abdu'l-Baha" => [11, 28],
    "Ayyam-i-Ha"                => [ 2, 26,  4],  # 5 days in leap years
    "The Fast"                  => [ 3,  2, 19],
    "Days of Ridvan"            => [ 4, 21, 12],
};
# }}}

# List return functions {{{
sub cycles { return CYCLE_YEAR }
sub years { return CYCLE_YEAR }
sub months { return MONTH_DAY }
sub days { return (MONTH_DAY)[0 .. 18] }
sub days_of_the_week { return DOW_NAME }
sub holy_days { return HOLY_DAYS }
# }}}

sub date { goto &to_bahai }
sub to_bahai {  # {{{
    my %args = @_;
    # readability++
    my ($year, $month, $day) = @args{qw(year month day)};

    # Use the system time, if a ymd is not provided.
    unless ($year && $month && $day) {
        $args{epoch} ||= time;

        ($year, $month, $day) = $args{use_gmtime}
            ? (gmtime $args{epoch})[5,4,3]
            : (localtime $args{epoch})[5,4,3];

        # Fix the year and the month.
        $year += ADJUST_YEAR;
        $month++;
    }

    my ($bahai_month, $bahai_day);

    for (values %{ MONTHS() }) {
        my ($days, $lower, $upper) = _setup_date_comparison(
            $year, $month, $day, @$_[1,2]
        );

        if ($days >= $lower && $days <= $upper) {
            $bahai_month = $_->[0];
            $bahai_day = $days - $lower;
            last;
        }
    }

    # Build the date hash to return.
    return _build_date (
        $year, $month, $day, $bahai_month, $bahai_day,
        %args
    );
}
# }}}

sub from_bahai {  # {{{
    my %args = @_;

    # Figure out the year.
    my $year = $args{year} + FIRST_YEAR;
    $year-- unless $args{month} > SHARAF || $args{month} == -1;

    # Reset the month number if we are given Ayyam-i-Ha.
    $args{month} = 0 if $args{month} == -1;

    # This ugliness actually finds the month and day number.
    my $day = (MONTHS->{ (MONTH_DAY)[$args{month} - 1] })->[1];
    (my $month, $day) = split /\./, $day;
    ($year, $month, $day) = Add_Delta_Days (
        $year, $month, $day, $args{day} - 1
    );

    return wantarray
        ? ($year, $month, $day)
        : join '/', $year, $month, $day;
}  # }}}

sub as_string {  # {{{
    # XXX With Lingua::Num2Word, naively assume that we only care
    # about English.
    my ($date_hash, %args) = @_;

    $args{size}     = 1 unless defined $args{size};
    $args{numeric}  = 0 unless defined $args{numeric};
    $args{alpha}    = 1 unless defined $args{alpha};
    $args{timezone} = 0 unless defined $args{timezone};

    my $date;

    if (!$args{size} && $args{numeric} && $args{alpha}) {
        # short alpha-numeric
        $date .= sprintf '%s (%d), %s (%d) of %s (%d), year %d, %s (%d) of %s (%d)',
            @$date_hash{qw(
                dow_name dow day_name day month_name month
                year year_name cycle_year cycle_name cycle
            )};
    }
    elsif ($args{size} && $args{numeric} && $args{alpha}) {
        # long alpha-numeric
        $date .= sprintf '%s week day %s, %s day %s of the %s month %s, year %s (%d), %s year %s of the %s vahid %s of the %s kull-i-shay',
            ordinate ($date_hash->{dow}), $date_hash->{dow_name},
            ordinate ($date_hash->{day}), $date_hash->{day_name},
            ordinate ($date_hash->{month}), $date_hash->{month_name},
            lc (Lingua::Num2Word::cardinal ('en', $date_hash->{year})),
            $date_hash->{year},
            ordinate ($date_hash->{cycle_year}),
            $date_hash->{year_name},
            ordinate ($date_hash->{cycle}),
            $date_hash->{cycle_name},
            ordinate ($date_hash->{kull_i_shay});
    }
    elsif (!$args{size} && $args{numeric}) {
        # short numeric
        $date .= sprintf '%s, %s/%s/%s',
            @$date_hash{qw(dow month day year)};
    }
    elsif ($args{size} && $args{numeric}) {
        # long numeric
        $date .= sprintf '%s day of the week, %s day of the %s month, year %s, %s year of the %s vahid of the %s kull-i-shay',
            ordinate ($date_hash->{dow}),
            ordinate ($date_hash->{day}),
            ordinate ($date_hash->{month}),
            $date_hash->{year},
            ordinate ($date_hash->{cycle_year}),
            ordinate ($date_hash->{cycle}),
            ordinate ($date_hash->{kull_i_shay});
    }
    elsif (!$args{size} && $args{alpha}) {
        # short alpha
        $date .= sprintf '%s, %s of %s, %s of %s',
            @$date_hash{qw(
                dow_name month_name day_name year_name cycle_name
            )};
    }
    else {
        # long alpha
        $date .= sprintf 'week day %s, day %s of month %s, year %s of year %s of the vahid %s of the %s kull-i-shay',
            @$date_hash{qw(dow_name day_name month_name)},
            lc (Lingua::Num2Word::cardinal ('en', $date_hash->{year})),
            @$date_hash{qw(year_name cycle_name)},
            ordinate ($date_hash->{kull_i_shay});
    }

    if ($args{timezone}) {
        #long numeric, short alpha: , TZ -6h
        if (($args{size} && $args{numeric} && !$args{alpha})
            ||
            (!$args{size} && !$args{numeric} && $args{alpha})
        ) {
            $date .= ", TZ $date_hash->{timezone}h";
        }
        #long alpha: , with timezone offset of negative six hours
        elsif ($args{size} && $args{alpha}) {
            $date .= ', with timezone offset of ' .
                lc (Lingua::Num2Word::cardinal ('en', $date_hash->{timezone})) .
                ' hours';
        }
        #short numeric: , -6
        else {
            $date .= ", $date_hash->{timezone}";
        }
    }

    if ($date_hash->{holy_day} && $args{size}) {
        $date .= ', holy day: ' . join '', keys %{ $date_hash->{holy_day} };
    }

    return $date;
}  # }}}

sub next_holy_day {  # {{{
    my ($year, $month, $day) = @_;

    # Make the month and day a pseudo real number.
    my $m_d = "$month.$day";

    # Construct our lists of pseudo real number dates.
    my %inverted = _invert_holy_days ($year);
    my @sorted = sort { $a <=> $b } keys %inverted;

    my $holy_date;

    # Find the first date greater than the one provided.
    for (@sorted) {
        if ($m_d < $_) {
            $holy_date = $_;
            last;
        }
    }

    # If one was not found, just grab the last date in the list.
    $holy_date = $sorted[-1] unless $holy_date;

    return wantarray
        ? ( $inverted{$holy_date} => [ split /\./, $holy_date ] )
        : "$inverted{$holy_date}: $holy_date";
}  # }}}

# Helper functions {{{
# Date comparison gymnastics.
sub _setup_date_comparison {  # {{{
    my ($y, $m, $d, $s, $e) = @_;

    my ($start_month, $start_day) = split /\./, $s;
    my ($end_month, $end_day) = split /\./, $e;

    my ($start_year, $end_year) = ($y, $y);
    if ($end_month < $start_month) {
        if ($m == $start_month) {
            $end_year++;
        }
        elsif ($m == $end_month) {
            $start_year--;
        }
    }

    return
        Date_to_Days($y, $m, $d),
        Date_to_Days($start_year, $start_month, $start_day),
        Date_to_Days($end_year, $end_month, $end_day);
}  # }}}

sub _build_date {  # {{{
    my ($year, $month, $day, $new_month, $new_day, %args) = @_;

    my %date;
    @date{qw(month day)} = ($new_month, $new_day);

    # Set the day of the week (rotated by 2).
    $date{dow} = Day_of_Week ($year, $month, $day);
    $date{dow} += 2;
    $date{dow} = $date{dow} - 7 if $date{dow} > 7;
    $date{dow_name} = (DOW_NAME)[$date{dow} - 1];

    # Set the day.
    $date{day_name} = (MONTH_DAY)[$date{day}];
    $date{day}++;

    # Set the the month.
    $date{month_name} = (MONTH_DAY)[$date{month}];
    # Fix the month number, unless we are in Ayyam-i-Ha.
    $date{month}++ unless $date{month} == -1;

    # Set the year.
    # NOTE: This, as of yet, cryptic algorithm lifted from Arman
    # Danesh's "bahaidate".
    if (($month < MARCH) 
        ||
        ($month == MARCH && $day < YEAR_START_DAY)
    ) {
        $date{year} = $year - FIRST_YEAR;
    }
    else {
        $date{year} = $year - (FIRST_YEAR - 1);
    }

    $date{year_name} = (CYCLE_YEAR)[($date{year} - 1) % FACTOR];
    $date{cycle_year} = $date{year} % FACTOR;

    # Set the cycle.
    $date{cycle} = int ($date{year} / FACTOR) + 1;
    $date{cycle_name} = (CYCLE_YEAR)[($date{cycle} - 1) % FACTOR];

    # Set the Kull-i-Shay.
    $date{kull_i_shay} = int ($date{cycle} / FACTOR) + 1;

    # Naively assume only the hour item is the TZ offset.
    # ($D_y,$D_m,$D_d, $Dh,$Dm,$Ds, $dst) = Timezone ();
    $date{timezone} = (Timezone ())[3];

    # Get the holy day!
    my $m_d = $month .'.'. sprintf ('%02d', $day);
    my %inverted = _invert_holy_days ($year);
    $date{holy_day} = { $inverted{$m_d} => HOLY_DAYS->{$inverted{$m_d}} }
        if exists $inverted{$m_d};

    return wantarray ? %date : as_string (\%date, %args);
}  # }}}

sub _invert_holy_days {  # {{{
    my $year = shift || (localtime)[5] + ADJUST_YEAR;

    my %inverted;

    while (my ($name, $dates) = each %{ HOLY_DAYS() }) {
        # Pre-pad the day number with a zero.
        $inverted{ sprintf '%d.%02d', @$dates[0,1] } = $name;

        # Does this date contain a day span?
        if (@$dates == 3) {
            # Increment the Ayyam-i-Ha day if we are in a leap year.
            $dates->[2]++ if $name eq 'Ayyam-i-Ha' && leap_year ($year);

            for (1 .. $dates->[2] - 1) {
                (undef, my $month, my $day) = Add_Delta_Days($year, @$dates[0,1], $_);
                # Pre-pad the day number with a zero.
                $inverted{ sprintf '%d.%02d', $month, $day} = $name;
            }
        }
    }

    return %inverted;
}  # }}}
# }}}

1;
__END__

=head1 NAME

Date::Baha::i - Convert to and from Baha'i dates.

=head1 SYNOPSIS

  use Date::Baha'i;

  $bahai_date = to_bahai ();
  $bahai_date = to_bahai (epoch => time);
  $bahai_date = to_bahai (
      year  => $year,
      month => $month,
      day   => $day,
  );

  %bahai_date = to_bahai ();
  %bahai_date = to_bahai (epoch => time);
  %bahai_date = to_bahai (
      year  => $year,
      month => $month,
      day   => $day,
  );

  $date = from_bahai (
      year  => $bahai_year,
      month => $bahai_month,
      day   => $bahai_day,
  );

  ($year, $month, $day) = from_bahai (
      year  => $bahai_year,
      month => $bahai_month,
      day   => $bahai_day,
  );

  $holy_day = next_holy_day ($year, $month, $day);
  %holy_day = next_holy_day ($year, $month, $day);

  @cycles = cycles ();
  @years = years ();
  @months = months ();
  @days = days ();
  @days_of_the_week = days_of_the_week ();
  %holy_days = holy_days ();

=head1 ABSTRACT

This package converts between Baha'i and standard dates.

=head1 DESCRIPTION

This package renders the Baha'i date from two standard date formats -
epoch time and a year/month/day triple.  It also converts a Baha'i 
date to standard ymd format.

This package is not a date arithmetic calculator.  It simply takes a 
standard or Baha'i date and converts it to the reverse representation.

The Baha'i year is based on the solar year of 365 days, five hours and
some fifty minutes. Each year is divided into nineteen months of 
nineteen days each with four Intercalary Days (five in a leap year), 
called Ayyam-i-Ha which Baha'u'llah specified should precede the 
nineteenth month. New Year's Day (Naw Ruz) falls on the Spring 
Equinox. This usually occurs on 21 March but if the Equinox falls 
after sunset on 21 March, Naw Ruz is to be celebrated on 22 March 
because the Baha'i day begins at sunset.

The names of the months in the Baha'i (Badi) calendar were given by 
the Bab, who drew them from the nineteen names of God invoked in a 
prayer said during the month of fasting in Shi'ih Islam. They are:

  1.  Baha      - Splendour (21 March - 8 April)
  2.  Jalal     - Glory (9 April - 27 April)
  3.  Jamal     - Beauty (28 April - 16 May)
  4.  'Azamat   - Grandeur (17 May - 4 June)
  5.  Nur       - Light (5 June - 23 June)
  6.  Rahmat    - Mercy (24 June - 12 July)
  7.  Kalimat   - Words (13 July - 31 July)
  8.  Kamal     - Perfection (1 August - 19 August)
  9.  Asma'     - Names (20 August - 7 September)
  10. 'Izzat    - Might (8 September - 26 September)
  11. Mashiyyat - Will (27 September - 15 October)
  12. 'Ilm      - Knowledge (16 October - 3 November)
  13. Qudrat    - Power (4 November - 22 November)
  14. Qawl      - Speech (23 November - 11 December)
  15. Masa'il   - Questions (12 December - 30 December)
  16. Sharaf    - Honour (31 December - 18 January)
  17. Sultan    - Sovereignty (19 January - 6 February)
  18. Mulk      - Dominion (7 February - 25 February)
  * Ayyam-i-Ha  - Days of Ha (26 February - 1 March))
  19. 'Ala      - Loftiness (2 March - 20 March)

The days of the Baha'i week are;

  1. Jalal    - Glory (Saturday)
  2. Jamal    - Beauty (Sunday)
  3. Kaml     - Perfection (Monday)
  4. Fidal    - Grace (Tuesday)
  5. 'Idal    - Justice (Wednesday)
  6. Istijlal - Majesty (Thursday)
  7. Istiqlal - Independence (Friday)

The Baha'i day of rest is Isiqlal (Friday) and the Baha'i day begins 
and ends at sunset.

Each of the days of the month is also given the name of one of the 
attributes of God. The names are the same as those of the nineteen 
months. Thus Naw-Ruz, the first day of the first month, would be 
considered the 'day of Baha of the month Baha'. If it fell on a 
Saturday, the first day of the Baha'i week, it would be the 'day of 
jalal'.

Ayyam-i-Ha

Literally, Days of Ha (i.e. the letter Ha, which in the abjad system 
has the numerical value of 5). Intercalary Days. The four days (five 
in a leap year) before the last month of the Baha'a year, 'Ala', which
is the month of fasting. Baha'u'llah designated the Intercalary days 
as Ayyam-i-Ha in the Kitab-i-Aqdas and specified when they should be 
observed; the Bab left this undefined. The Ayyam-i-Ha are devoted to 
spiritual preparation for the fast, hospitality, feasting, charity and
gift giving.  

The Cycles (Vahid)

In His Writings, the Bab divided the years following the date of His 
Revelation into cycles of nineteen years each.

Each cycle of nineteen years is called a Vahid. Nineteen cycles 
constitute a period called Kull-i-Shay.

The names of the years in each cycle are: 

  1.  Alif   - The Letter "A"
  2.  Ba     - The letter "B"
  3.  Ab     - Father
  4.  Dal    - The letter "D"
  5.  Bab    - Gate
  6.  Vav    - The letter "V"
  7.  Abad   - Eternity
  8.  Jad    - Generosity
  9.  Baha   - Splendour
  10. Hubb   - Love
  11. Bahhaj - Delightful
  12. Javab  - Answer
  13. Ahad   - Single
  14. Vahhab - Bountiful
  15. Vidad  - Affection
  16. Badi   - Beginning
  17. Bahi   - Luminous
  18. Abha   - Most Luminous
  19. Vahid  - Unity

There are eleven Holy Days which Baha'is celebrate. On [many] of these
days, all work should cease. They are listed in chronological order 
according to the Baha'i calendar.

* Naw Ruz - March 21

Literally, New Day. The Baha'i New Year. Like the ancient Persian New 
Year, it occurs on the spring equinox, which generally falls on 21 
March. If the equinox falls after sunset on 21 March, Naw Ruz is 
celebrated on 22 March, since the Baha'i day begins at sunset. For the
present, however, the celebration of Naw Ruz is fixed on 21 March. In 
the Baha'i calandar, Naw Ruz falls on the day of Baha of the month of 
Baha. The Festival of Naw Ruz marks the end of the month of fasting 
and is a joyous time of celebration. It is a Baha'i Holy Day on which 
work is to be suspended.

* Ridvan

First day - 21 April; Ninth day - 29 April; Twelfth day - 2 May

The Ridvan (pronouced "riz-wan") festival commemorates the first 
public declaration by Baha'u'llah of His Station and mission (in 
1863).

* Declaration of the Bab - 23 May

Commemorates the date in 1844 when the Bab first declared His mission.

* Ascension of Baha'u'llah - 29 May

Commemorates the date in 1892 when Baha'u'llah passed away.

* Martyrdom of the Bab - 9 July

Commemorates the date in 1850 when the Bab was executed by a 750-man 
firing squad in Tabriz, Ira.

* Birth of the Bab - 20 October

Commemorates the date in 1819 when the Bab was born in Shiraz, Iran

* Birth of Baha'u'llah - 12 November

Commemorates the date in 1817 when Baha'u'llah was born in Tihran, 
Iran

- Work does not have to cease on these Holy Days:

* Day of the Covenant - 26 November

This day is celebrated in lieu of the Birth of 'Abdu'l-Baha, which 
falls on the same day as the Declaration of the Bab.

* Ascension of 'Abdu'l-Baha - 28 November

Commemorates the day in 1921 when 'Abdu'l-Baha passed away.

* Ayyam-i-Ha - the Intercalary Days - 26 February - 1 March

The Baha'i calendar is made up of 19 months of 19 days each. The 
period of Ayyam-i-Ha adjusts the Baha'i year to the solar cycle. These
days are set aside for hospitality, gift-giving, special acts of 
charity, and preparing for the Baha'i Fast.

* The Fast - 'Ala - Loftiness (month 19) / 2-20 March

Baha'is fast for 19 days from sunrise to sunset, setting aside time 
for prayer and meditation. Children under the age of 15, individuals 
who are ill, travelers, the elderly, pregnant women and nursing 
mothers are exempt from the fast.

Text taken from

L<http://www.bahaindex.com/calendar.html>

Baha'i Calendar

(days start on the evening before the Gregorian date given)

This new calendar was instituted by the Baha'i spiritual leader 
Baha'u'llah, who stated that it should begin in the Gregorian year 
1844 at the (northern) Spring equinox, which is the traditional 
Iranian New Year. According to calendars rules, the year begins at the
sunset following the equinox, but up to now the practice in the West 
has been to start the year at sunset on 20 March. This is usually 
shown as 21 March, with the understanding that the day begins on the 
evening before. In the Middle East, Baha'is start the year at the 
sunset in Tehran following the equinox, and the Baha'i Universal House
of Justice has not yet decided on the rules of the calendar to be used
by all (Reingold and Dershowitz: Calendrical Calculations 2001). For 
now, I present the calendar as used in the West.

Baha'u'llah proclaimed the fulfillment of all religions and the unity 
of humankind, and the calendar is designed to be a world calendar, 
(relatively) free of cultural baggage. It is an entirely solar 
calendar, without even the vestige of previously lunar months as in 
the Gregorian Calendar. It has nineteen months of nineteen days, with 
some extra days before the last month. The cycle of 19 names is used 
for the names of both the months and the days.

The Vahid is a period of 19 years, and a Kull-i-Shay is 19 Vahids (361
years). These cycles have another set of names: Alif (A,1), Ba (B,2), 
Ab (Father,3), Dal (D,4), Bab (Gate,5), Vav (V,6), Abad (Eternity,7), 
Jad (Generosity,8), Baha (Splendour,9), Hubb (Love,10), Bahhaj 
(Delightful,11), Javab (Answer,12), Ahad (Single,13), Vahhab 
(Bountiful,14), Vidad (Affection,15), Badi (Beginning,16), Bahi 
(Luminous,17), Abha (Most Luminous,18), Vahid (Unity,19).

The weekly seven day cycle is still used, and the day of rest is 
Friday.

Text taken from

L<http://www.moonwise.co.uk/year/159bahai.htm>

=head1 EXPORTED FUNCTIONS

=head2 to_bahai

  # Return a string in scalar context.
  $bahai_date = to_bahai ();
  $bahai_date = to_bahai (
      epoch => time,
      use_gmtime => $use_gmtime,
      %args,
  );

  $bahai_date = to_bahai (
      year  => $year,
      month => $month,
      day   => $day,
      %args,
  );

  # Return a hash in array context.
  %bahai_date = to_bahai ();
  %bahai_date = to_bahai (
      epoch => time,
      use_gmtime => $use_gmtime,
      %args,
  );

  %bahai_date = to_bahai (
      year  => $year,
      month => $month,
      day   => $day,
      %args,
  );

This function returns either a string or a hash of the Baha'i date 
names and numbers from either epoch seconds or a year, month, day 
triple.

If using epoch seconds, this function can be forced to use gmtime 
instead of localtime.  If neither a epoch or ymd triple are given, 
the system localtime (or gmtime) are used as a default.

The extra arguments are most handy, and used by the as_string 
function, detailed below.

In a scalar context, this function returns a string sentence with the 
numeric and/or named Baha'i date.  In an array context, it returns a 
hash with the following keys:

  kull_i_shay,
  cycle, cycle_name, cycle_year,
  year, year_name,
  month, month_name,
  day, day_name,
  dow, dow_name,
  timezone, and
  holy_day, if there is one.

=head2 from_bahai

  # Return a y/m/d string in scalar context.
  $date = from_bahai (
      year  => $bahai_year,
      month => $bahai_month,
      day   => $bahai_day,
  );

  # Return a ymd triple in array context.
  ($year, $month, $day) = from_bahai (
      year  => $bahai_year,
      month => $bahai_month,
      day   => $bahai_day,
  );

This function returns either a string or a list of the standard date 
from a year, month, day triple of the Baha'i date.

* Currently, this only supports the Baha'i year, month and day.  The
Baha'i cycle and Kull-i-Shay are coming soon, to a theatre near you...

=head2 as_string

  $date = as_string (
      \%bahai_date,
      size     => $size,
      alpha    => $alpha,
      numeric  => $numeric,
      timezone => $timezone,
  );

Return the Baha'i date as a friendly string.

This function takes a Baha'i date hash and Boolean arguments that 
determine the format of the output.

The "size" argument toggles between short and long representations.
The "timezone" argument toggles the display of the time zone offset.
As the names imply, the "alpha" and "numeric" flags turn the 
alphanumeric representations on or off.  The defaults are as follows:

  size     => 1
  alpha    => 1
  numeric  => 0
  timezone => 0

Thus, "long non-numeric alpha without the timezone" is the default 
representation.

Here are some handy examples (newlines added for readability):

  short numeric:
  7, 1/1/159

  short numeric with TZ:
  7, 1/1/159, -6

  long numeric:
  7th day of the week, 1st day of the 1st month, year 159,
  7th year of the 9th vahid of the 1st kull-i-shay, holy day: Naw Ruz

  long numeric with TZ:
  7th day of the week, 1st day of the 1st month, year 159,
  7th year of the 9th vahid of the 1st kull-i-shay, TZ -6h,
  holy day: Naw Ruz

  short alpha:
  Istiqlal, Baha of Baha, Abad of Baha

  short alpha with TZ:
  Istiqlal, Baha of Baha, Abad of Baha, TZ -6h

  long alpha:
  week day Istiqlal, day Baha of month Baha,
  year one hundred fifty nine of year Abad of the vahid Baha of the
  1st kull-i-shay, holy day: Naw Ruz

  long alpha with TZ:
  week day Istiqlal, day Baha of month Baha,
  year one hundred fifty nine of year Abad of the vahid Baha of the
  1st kull-i-shay, with timezone offset of negative six hours,
  holy day: Naw Ruz

  short alpha-numeric:
  Istiqlal (7), Baha (1) of Baha (1), year 159, Abad (7) of Baha (9)

  short alpha-numeric with TZ:
  Istiqlal (7), Baha (1) of Baha (1), year 159, Abad (7) of Baha (9),
  TZ -6h

  long alpha-numeric:
  7th week day Istiqlal, 1st day Baha of the 1st month Baha,
  year one hundred fifty nine (159), 7th year Abad of the
  9th vahid Baha of the 1st kull-i-shay, holy day: Naw Ruz

  long alpha-numeric with TZ:
  7th week day Istiqlal, 1st day Baha of the 1st month Baha,
  year one hundred fifty nine (159), 7th year Abad of the
  9th vahid Baha of the 1st kull-i-shay,
  with timezone offset of negative six hours, holy day: Naw Ruz

=head2 next_holy_day

  %holy_day = next_holy_day ($year, $month, $day);
  $holy_day = next_holy_day ($year, $month, $day);

This function returns the first holy day after the provided date
triple as either a hash (in array context) or a string (in scalar 
context).

In array context, a hash with a single key (the name of the holy day)
and a two or three element array reference of [month, day, duration]
as the value.

=head2 cycles

  @cycles = cycles ();

This function returns the 19 cycle names as an array.

=head2 years

  @years = years ();

This function returns the 19 year names as an array.

=head2 months

  @months = months ();

This function returns the 19 month names as an array, along with the 
intercalary days (Ayyam-i-Ha) as the last element.

=head2 days

  @days = days ();

This function returns the 19 day names as an array.

=head2 days_of_the_week

  @days = days_of_the_week ();

This function returns the 7 day-of-the-week names as an array.

=head2 holy_days

  %days = holy_days ();

This function returns the holy days as a hash, where the keys are 
the holy day names and the values are array references.  These array 
references are composed of two or three elements, where the first is 
the month, the second is the day, and the third is the (optional) 
number of days observed.  These dates are saved in standard 
(non-Baha'i) format.

=head1 DEPENDENCIES

L<Date::Calc>

L<Lingua::EN::Numbers::Ordinate>

L<Lingua::Num2Word>

=head1 TO DO

Factor out the fugly _invert_holy_days function.

Optionally output unicode.

Base the date computation on the time of day (the Baha'i day begins at 
Sunset) and the location longitude/latitude.

Overload localtime and gmtime, just to be cool?

=head1 DEDICATION

Hi Kirsten  : )

=head1 REFERENCES

L<http://www.projectpluto.com/calendar.htm#bahai>

L<http://www.bahaindex.com/calendar.html>

L<http://www.moonwise.co.uk/year/159bahai.htm>

L<http://www.perl.com/pub/a/2003/03/13/datetime.html>

=head1 AUTHOR

Gene Boggs E<lt>cpan@ology.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Gene Boggs

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
