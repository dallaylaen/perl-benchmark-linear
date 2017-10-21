#!/usr/bin/env perl

use strict;
use warnings;
use Time::HiRes qw(sleep);
use Benchmark::Linear qw(bench);

print "'Benchmarking' a sleep( n/100 )\n";

my $bl = bench {
    warn "Arg: $_";
    sleep( $_ / 100 );
};

printf "Operations per second: %f\n", $bl->ops_per_sec;
