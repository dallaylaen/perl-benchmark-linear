package Benchmark::Linear::Fun;

use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw( derivative derivative2 find_minimum gradient );
our $DELTA = 1E-6;


sub find_minimum {
    my (%opt) = @_;

    my $fun   = $opt{fun};
    my $start = $opt{start} || [];
    my $delta = $opt{delta} || [];
    my $n     = $opt{n}   || scalar @$start;

    $start->[$_] ||= 0      for 0 .. $n-1;
    $delta->[$_] ||= $DELTA for 0 .. $n-1;

    for (1 .. 20) {
        # build gradient
        my $grad = gradient( fun => $fun, arg => $start, delta => $delta );

        # find quadric minimum
        my $uni  = sub {
            return $fun->( linear_offset($start, $grad, $_[0]) );
        };
        my $offset = quadratic_extremum( $uni );
        my $new_start = [ linear_offset($start, $grad, $offset ) ];

        # check if near
        warn "min[$_]: (@$start) + (@$grad)*$offset = (@$new_start)";

        return $start
            if !grep { abs($start->[$_] - $new_start->[$_]) > $delta->[$_] } 0 .. $n-1;

        # move there
        $start = $new_start;
    };

    die "Failed to find minimum";
};

sub linear_offset {
    my ($x, $v, $t) = @_;
    return map { $x->[$_] + $v->[$_] * $t } 0 .. scalar @$x-1;
};

sub gradient {
    my (%opt) = @_;

    my $fun      = $opt{fun};
    my $arg      = $opt{arg};
    my $delta    = $opt{delta};
    my $n        = scalar @$arg;

    $delta->[$_] ||= $DELTA for 0 .. $n-1;

    my @ret;
    foreach (0 .. $n-1) {
        my $i     = $_; # closure
        my @param = @$arg;
        my $uni   = sub {
            $param[$i] = shift;
            return $fun->(@param);
        };
        push @ret, derivative($uni, $arg->[$i], $delta->[$i] );
    };

    return \@ret;
};

sub quadratic_extremum {
    my ($fun, $start, $dx) = @_;

    $start ||= 0;
    $dx    ||= $DELTA;

    my $const  = derivative( $fun, $start, $dx );
    my $linear = derivative2( $fun, $start, $dx );

    return $start if abs($linear) < $dx;

    return $start - $const / $linear;
};

sub derivative {
    my ($fun, $x, $dx) = @_;

    # TODO sane default
    $dx ||= $DELTA;

    # TODO cubic
    return ($fun->($x+$dx) - $fun->($x-$dx)) / ($dx+$dx);
}

sub derivative2 {
    my ($fun, $x, $dx) = @_;
    # TODO sane default
    $dx ||= $DELTA;

    my $first = sub { return derivative( $fun, $_[0], $dx ) };
    # TODO approx
    return derivative( $first, $x, $dx );
};




1;
