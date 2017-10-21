package Benchmark::Linear::Compare;

use Moo;
our $VERSION = 0.0101;

extends 'Benchmark::Linear';

use overload '""' => \&to_string;

has todo    => is => 'ro', default => sub { {} };
has results => is => 'ro', default => sub { {} };
has verbose => is => 'ro';

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
