#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use Benchmark::Linear::Approx;

my $ap = Benchmark::Linear::Approx->new ( const => 42, linear => 137 );

is "$ap", "42+137*n", "Stringified";
is $ap <=> 137, 0, "Comparison";
ok $ap > 0, "Comparison > 0";

done_testing;
