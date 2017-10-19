#!/usr/bin/env perl

use strict;
use warnings;
use Time::HiRes qw(sleep);
use Benchmark::Linear qw(bench);

my $bl = bench {
    sleep $_ / 100;
};

printf "Avg sleep time: %f\n", $bl->time_per_op;
