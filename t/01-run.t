#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use Benchmark::Linear;

my %trace;
my $bl = Benchmark::Linear->new( code => sub {$trace{ shift() } ++} );

$bl->run;

note "Tested: ".join ", ", sort { $a <=> $b } keys %trace;

# currently hardcoded 5 reps per key
my @double = grep { $trace{$_} != 5 } keys %trace;
is (scalar @double, 0, "Each step executed exactly 5 times")
    or diag "MEasured twice: @double";

cmp_ok( scalar keys %trace, ">", 10, "More than 10 pts" );

is_deeply( [sort keys %trace], [sort keys %{ $bl->run } ]
    , "Run keys == trace keys" );

done_testing;
