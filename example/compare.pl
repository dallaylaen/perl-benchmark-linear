#!/usr/bin/env perl

use strict;
use warnings;

use Benchmark::Linear qw(bench_all);

my %cache;

print bench_all {
    max_time => 1,
    verbose => 1,
    repeat => 1,
    init => sub { 
        return $cache{$_[0]} ||= [ map { "x$_" } 1 .. $_[0] ];
    },
}, {
    join => sub {
        my ($n,  $env) = @_;
        return join " ", @$env;
    },
    inter => sub {
        my ($n, $env) = @_;
        return "@$env";
    },
    naive => sub {
        my ($n, $env) = @_;
        my $all = shift @$env;
        $all .= " $_" for @$env;
        return $all;
    },
};


