package Benchmark::Linear::Approx;

use Moo;
our $VERSION = 0.0102;

=head1 NAME

Benchmark::Linear::Approx - Parametric benchmark linear model.

=head1 DESCRIPTION

This module provides linear approximation for agiven set of data.

=cut

has const  => is => 'ro', default => sub { 0 };
has linear => is => 'ro', default => sub { 0 };

use overload
    '""'   => 'to_string',
    '<=>'  => 'cmp';
    # TODO arithmetics, too

=head2 new( %options )

=over

=item * const -

=item * linear -

=back

=head2 infer( \@data )

A static method returning a new object.

The \@data is expected to consist of [argument, value, (weight?)]
tuples. Weight is assumed to be 1 if omitted.

A least square method approximation is performed.

=cut

sub infer {
    my ($class, $pairs) = @_; # [[x, f(x), weight?], ... ]

    my( $n, $x, $y, $x2, $xy);
    foreach (@$pairs) {
        my $wt = $_->[2] || 1;

        $x  += $wt * $_->[0];
        $y  += $wt * $_->[1];
        $x2 += $wt * $_->[0]*$_->[0];
        $xy += $wt * $_->[0]*$_->[1];
        $n  += $wt;
    };

    # y =~ A*x + B;
    my $A = ($xy - $x*$y/$n) / ($x2 - $x*$x/$n);
    my $B = ($y - $A*$x) / $n;

    return $class->new( linear => $A, const => $B);
};

=head2 calc( $arg )

Get expected value for argument $arg.

=cut

sub calc {
    my ($self, $arg) = @_;
    return $self->const + $self->linear * $arg;
};

=head2 to_string

Returns "$const+$linear*n".

=cut

sub to_string {
    my $self = shift;
    return $self->const . "+" . $self->linear . '*n';
};

=head2 cmp

Compares to a number or another L<Benchmark::Linear::Approx> object.
C<linear> coefficient is used while the C<const> part is omitted.

=cut

sub cmp {
    my ($self, $arg, $inv) = @_;

    return $inv ? $arg <=> $self->linear : $self->linear <=> $arg;
};

1;
