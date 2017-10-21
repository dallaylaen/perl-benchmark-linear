#!/usr/bin/env perl

use strict;
use warnings;
use Time::HiRes qw(time sleep);

use Benchmark::Linear;

my $bl = Benchmark::Linear->new(
    code => sub { sleep $_/100 },
    cleanup => sub { print "Done sleep $_/100\n" },
);

my $t0 = time;
$bl->run( max_time => 1 );
my $time = time - $t0;

print "Total elapsed time = $time\n";
print "time per step in sleep = ".$bl->get_approx->linear;


