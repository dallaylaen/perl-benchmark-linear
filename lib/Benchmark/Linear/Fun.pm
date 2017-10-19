package Benchmark::Linear::Fun;

use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(derivative derivative2);
our $DELTA = 1E-6;

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
