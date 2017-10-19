#!/usr/bin/env perl

use strict;
use warnings;
use Time::HiRes qw(time sleep);

use Benchmark::Linear;

my $bl = Benchmark::Linear->new( code => sub { sleep $_/100 }, cleanup => sub { print "Done $_\n" } );

my $t0 = time;
$bl->run( max_time => 1 );
my $time = time - $t0;

print "runtime = $time\n";
print "time per step in sleep = ".$bl->time_per_op;


