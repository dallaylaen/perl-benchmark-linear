package Benchmark::Linear;

use 5.010;
use Moo;
our $VERSION = 0.0104;

=head1 NAME

Benchmark::Linear - Benchmark a function with one integer parameter.

=head1 DESCRIPTION

This module tries to infer the performance of a uniparametric function.

In the simplest case it's just the number of repetitions,
but it may also be a sample size, or anything else.
It is assumed that execution time grows with (n).

=cut

=head1 SYNOPSIS

    use Benchmark::Linear;

    my $bench = Benchmark::Linear->new( code => \&myfun );

    my ($avg, $disp) = $bench->run("infer_linear");

=head1 METHODS

=cut

use Time::HiRes qw(time);
use Carp;
use Exporter qw(import);
our @EXPORT_OK = qw(bench bench_all);

use Benchmark::Linear::Approx;

my @CLONEABLE = qw( min_arg max_arg max_time repeat init cleanup code );

my $nocode = sub { };
has init      => is => 'ro', default => sub { $nocode };
has code      => is => 'ro';
has cleanup   => is => 'ro', default => sub { $nocode };
has min_arg   => is => 'ro', default => sub { 1 };
has max_arg   => is => 'ro', default => sub { 1_000_000 };
has max_time  => is => 'ro';
has repeat    => is => 'ro', default => sub { 5 };
has elapsed   => is => 'ro', default => sub { 0 };
has stat      => is => 'ro', default => sub { {} }, reader => 'get_stat';

=head2 bench { CODE; } [ option => ... ];

Run a benchmark and return a L<Benchmark::Linear> object
with statistics populated.

=cut

sub bench(&@) {
    my ($code, %opt) = @_;

    $opt{code} = $code;
    $opt{max_time} ||= 1;

    croak( "Useless use of bench{ ... } in void context" )
        unless defined wantarray;

    # TODO filter options
    my $bl = __PACKAGE__->new( %opt );
    $bl->run( %opt );

    return $bl;
};

sub bench_all {
    my $fun = pop;
    my $opt = shift || {};

    require Benchmark::Linear::Compare;
    my $blc = Benchmark::Linear::Compare->new(
        max_time => 1, %$opt, todo => $fun );
    $blc->run;
    return $blc;
};

sub clone {
    my ($self, %opt) = @_;

    $opt{$_} //= $self->$_ for @CLONEABLE;
    return (ref $self)->new( %opt );
};

sub run {
    my ($self, %opt) = @_;

    # TODO infer count from min, max
    $opt{count}    ||= $self->default_count;
    $opt{max_time} ||= $self->max_time;
    $opt{repeat}   ||= $self->repeat;

    $self->_croak( "count=[...] is required" )
        unless ref $opt{count} eq 'ARRAY';

    # If external code supplied, make a clean obj for new stat
    $self = $self->clone( code => $opt{code} )
        if ($opt{code});

    $self->_croak("code is required in either new() or run()")
        unless $self->code;

    # TODO run auto!
    my $elapsed = 0;
    foreach my $n ( @{ $opt{count} } ) {
        my @stat = $self->run_point( $n, $opt{repeat} );
        $self->{stat}{$n} = \@stat;
        $elapsed += $stat[0] * $stat[2];
        last if $opt{max_time} and $elapsed > $opt{max_time};
    };
    $self->{elapsed} += $elapsed;

    return $self;
};

sub run_point {
    my ($self, $n, $repeat) = @_;

    $repeat ||= $self->repeat;

    # run the code
    my ($s, $s2);
    my $code = $self->code;
    for my $i ( 1 .. $repeat ) {
        local $_ = $n;
        my $env = $self->init->($n);
        my $t0 = time;
        $code->($n, $env);
        my $t = time - $t0;
        $s  += $t;
        $s2 += $t*$t;
        $self->cleanup->($n, $env);
    };

    # preprocess stats
    my $average = $s / $repeat;
    my $sigma   = $s2/$repeat - $average*$average;
    $sigma = $sigma <= 0 ? 0 : sqrt($sigma);

    # TODO or just [] and let user choose?
    return wantarray ? ($average, $sigma, $repeat) : $average;
};

sub get_approx {
    my $self = shift;
    my $data = shift || $self->get_stat;

    # TODO Add weight based on dispersion
    my @work = map { [ $_ => $data->{$_}[0] ] } keys %$data;

    return $self->approx->infer( \@work );
};

sub ops_per_sec {
    my $self = shift;
    return 1 / $self->get_approx->linear;
};

sub approx {
    return 'Benchmark::Linear::Approx';
};

sub default_count {
    my $self = shift;

    my $n = $self->min_arg;
    my @ret;
    while ($n <= $self->max_arg) {
        push @ret, $n;
        $n = int (($n * 3 + 1)/2);
    };

    return \@ret;
};

sub _croak {
    my ($self, $msg) = @_;

    my @stack = caller(1);
    my $fun = $stack[3];
    $fun =~ s/^.*:://;

    Carp::croak( (ref $self || $self)."->$fun(): $msg" );
};

=head1 AUTHOR

Konstantin S. Uvarin, C<< <khedin at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-benchmark-linear at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Benchmark-Linear>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Benchmark::Linear


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Benchmark-Linear>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Benchmark-Linear>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Benchmark-Linear>

=item * Search CPAN

L<http://search.cpan.org/dist/Benchmark-Linear/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2017 Konstantin S. Uvarin.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Benchmark::Linear
