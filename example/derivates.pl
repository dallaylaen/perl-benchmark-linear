#!/usr/bin/env perl

use strict;
use warnings;
use Carp;

use Benchmark::Linear::Fun qw( derivative derivative2 );

$SIG{__DIE__} = \&Carp::confess;

my $exp = sub { exp $_[0] };

foreach (-1, 0, 1, 2) {
    print_result( $exp, $_ );
};

sub print_result {
    my ($fun, $arg) = @_;

    my $data = measure( $fun, $arg );
    printf "x=%f; value=%f; d/dx=%f; d2/dx2=%f\n", @$data;
};

sub measure {
    my ($fun, $arg) = @_;

    return [ $arg, $fun->($arg), derivative( $fun, $arg ), derivative2( $fun, $arg ) ];
};

