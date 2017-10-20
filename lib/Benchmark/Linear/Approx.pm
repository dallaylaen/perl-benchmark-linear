package Benchmark::Linear::Approx;

use Moo;
our $VERSION = 0.0101;

has const  => is => 'ro', default => sub { 0 };
has linear => is => 'ro', default => sub { 0 };

use overload 
    '""'   => 'to_string',
    '<=>'  => 'cmp';

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

sub calc {
    my ($self, $arg) = @_;
    return $self->const + $self->linear * $arg;
};

sub to_string {
    my $self = shift;
    return $self->const . "+" . $self->linear . '*n';
};

sub cmp {
    my ($self, $arg, $inv) = @_;

    return $inv ? $arg <=> $self->linear : $self->linear <=> $arg;
};

1;
