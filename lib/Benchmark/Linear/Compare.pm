package Benchmark::Linear::Compare;

use Moo;
our $VERSION = 0.0102;

=head1 NAME

Benchmark::Linear::Compare - Parametric Big-O(n) performance measurement.

=head1 DESCRIPTION

This module is part of L<Benchmark::Linear> suite.
See C<bench_all> function.

=head1 METHODS

=cut

extends 'Benchmark::Linear';

use overload '""' => \&to_string;

has todo    => is => 'ro', default => sub { {} };
has results => is => 'ro', default => sub { {} };
has verbose => is => 'ro';

=head2 new

All arguments of L<Benchmark::Linear> are accepted, plus

=over

=item * todo { name => \&sub, ... } - code snippets to be compared.

=item * verbose - provide some warns during execution.

=back

=head2 run

No arguments accepted.
Benchmark ALL functions from the C<todo> hash
and collect the resulting L<Benchmark::Linear> objects under C<results>.

Self is returned.

=cut

sub run {
    my $self = shift;

    my $todo = $self->todo || shift;
    foreach (keys %$todo) {
        warn __PACKAGE__.": executing $_...\n"
            if $self->verbose;
        $self->results->{$_} = $self->SUPER::run( code => $todo->{$_} );
        warn __PACKAGE__.": done $_, time=".$self->results->{$_}->elapsed."s\n"
            if $self->verbose;
    };

    return $self;
};

=head2 to_string

Format a comparison table similar to that of L<Benchmark>.



=cut

sub to_string {
    my $self = shift;

    my $res = $self->results;
    my $cross = _cross_table( map { $_ => $res->{$_}->ops_per_sec } keys %$res );

    my @head  = qw( name op/sec );
    push @head, map { $_->[0] } @$cross;

    my @table = (\@head, @$cross);

    return _tabulate( \@table );
};

# TODO find module!!!!
sub _tabulate {
    my $tab = shift;

    my @width;
    foreach my $line( @$tab ) {
        foreach (0 .. @$line-1) {
            $width[$_] and $width[$_] >= length $line->[$_]
                or $width[$_] = length $line->[$_];
        }
    };
    @width = map { "%${_}s" } @width;

    foreach my $line( @$tab ) {
        foreach (0 .. @$line-1) {
            $line->[$_] = sprintf $width[$_], $line->[$_];
        }
    };

    return join "\n", map { join " ", @$_ } @$tab, [];
};

sub _cross_table {
    my %in = @_;

    my @raw = map { [ $_ => $in{$_} ] }
        sort { $in{$a} <=> $in{$b} } keys %in;

    foreach my $line ( @raw ) {
        push @$line, map { _percent_diff($_->[1], $line->[1]) } @raw;
    };
    $_->[1] > 100 and $_->[1] = sprintf "%0.0f", $_->[1]
        for @raw;

    return \@raw;
};

sub _percent_diff {
    my ($old, $new) = @_;

    return "--" if $old == $new;

    my $diff = $new / $old;
    if ($diff < 1/1.6 || $diff > 1.6) {
        return sprintf "x%1.1f", $diff;
    } else {
        return sprintf "%1.0f%%", ($diff - 1) * 100;
    };
};

1;
