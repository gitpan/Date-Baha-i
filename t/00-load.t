#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Date::Baha::i' ) || print "Bail out!
";
}

diag( "Testing Date::Baha::i $Date::Baha::i::VERSION, Perl $], $^X" );
