#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use Benchmark::Linear qw(bench_all);

my $blc = bench_all {
    count  => [ 1, 3, 7 ],
    repeat => 1,
}, {
    foo => sub { for ( 1 .. $_*100 ) { } },
    bar => sub { for ( 1 .. $_*200 ) { } },
};

isa_ok $blc, "Benchmark::Linear::Compare", "bench_all result";
note $blc;

my $stat = $blc->results;

is_deeply [ sort keys %$stat ], [qw[bar foo]], "Keys in result as exp";

my $foo_stat = $stat->{foo};

is_deeply [ sort keys %{ $foo_stat->get_stat } ], [1,3,7]
    , "Count array retained";

done_testing;
