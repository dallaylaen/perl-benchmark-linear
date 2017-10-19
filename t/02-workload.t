#!perl

use strict;
use warnings;
use Test::More;

use Benchmark::Linear;

my $bl = Benchmark::Linear->new( code => sub { my $s; $s += $_ for 1 .. shift } );

$bl->run( count => [ map { 100 * 2 ** $_ } 1 .. 10 ] );

note "Stat collected: ", explain $bl->stat;

my $time_per_op = $bl->time_per_op;

cmp_ok( $time_per_op, '>', 0, "Time per op = $time_per_op is positive" );

my $stat = $bl->stat;
note "Timings by op: ", join ", ", map { $stat->{$_}[0]/$_ } 
    sort { $a <=> $b } keys %$stat;

done_testing;


