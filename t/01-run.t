#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use Benchmark::Linear;

my %trace;
my $bl = Benchmark::Linear->new( code => sub {$trace{ shift() } ++} );

my $todo = [ map { 2 ** $_ } 1 .. 10 ];

$bl->run( count => $todo );

note "Tested: ".join ", ", sort { $a <=> $b } keys %trace;

# currently hardcoded 5 reps per key
my @wrong_repeat = grep { $trace{$_} != 5 } keys %trace;
is (scalar @wrong_repeat, 0, "Each step executed exactly 5 times")
    or diag explain \%trace;

is( scalar keys %trace, 10, "Exactly 10 pts" );

is_deeply( [sort keys %trace], [sort keys %{ $bl->get_stat } ]
    , "Stat keys == trace keys" );

done_testing;
