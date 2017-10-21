#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use Benchmark::Linear;

my $bl = Benchmark::Linear->new;

is $bl->min_arg, 1, "min_arg = 1 by default";

is $bl->clone( min_arg => 100 )->min_arg, 100, "clone subst works";
is $bl->clone( max_arg => 100 )->min_arg, 1, "clone no subst works";


done_testing;
