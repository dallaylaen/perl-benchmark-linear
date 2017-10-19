#!/usr/bin/env perl

use strict;
use warnings;

use Benchmark::Linear::Fun qw(find_minimum);

my $fun = sub {
    my ($x, $y) = @_;

    return 100 + exp ($x - 3) + exp (3 - $x) + ($y - 4) * ($y - 4);
};

my $min = find_minimum( fun => $fun, n => 2 );

printf "min: f(%f, %f) = %f\n", @$min, $fun->(@$min);

