package Benchmark::Linear::Approx;

use Moo;

has const  => is => 'ro', default => sub { 0 };
has linear => is => 'ro', default => sub { 0 };

use overload 
    '""'   => 'to_string',
    '<=>'  => 'cmp';

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
