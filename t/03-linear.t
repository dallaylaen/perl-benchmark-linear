#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use Benchmark::Linear;

my $bench = Benchmark::Linear->new( code => sub {} );

my @data = map { [ $_ => 42 * $_ + 137 ] } map { 2 ** $_ } 1 .. 8;

my ($A, $B) = $bench->linear_approx( \@data );

# TODO Test::Delta or smth
is $A, 42, "Guessed coeff";
is $B, 137, "Guessed free";

done_testing;



