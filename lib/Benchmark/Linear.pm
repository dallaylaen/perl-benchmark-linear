package Benchmark::Linear;

use 5.006;
use strict;
use warnings;
our $VERSION = 0.0101;

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

=head2 new

=cut

sub new {
    my ($class, %opt) = @_;

    ref $opt{code} eq 'CODE'
        or croak "$class->new(): 'code' is required and must be a function";
    $opt{max_time} ||= 0.2;
    $opt{min_arg}  ||= 1;
    $opt{max_arg}  ||= 2**45;

    return bless \%opt, $class;
};

sub run {
    my ($self, $fun) = @_;

    $self->_croak( "Unknown analysis type $fun" )
        unless !$fun or $self->can($fun);

    $self->{data} ||= $self->do_run;

    return $fun ? $self->$fun( $self->{data} ) : $self->{data}; 
};

sub do_run {
    my ($self, %opt) = @_;

    my %ret;

    my $n = $self->{min_arg};
    my $t = 0; # cumulative run time

    # generate enough data first
    foreach my $lead (1 .. 10) {
        $t += $ret{$n} = $self->run_step($n);
        $n++;
    };
    # increase until exec_time >= max_exec or x1024
    while( $n < $self->{max_arg} and $t < $self->{max_time}) {
        $t += $ret{$n} = $self->run_step($n);
        $n = int(3 * $n / 2 + 1);
    };

    return \%ret;
};

sub run_step {
    my ($self, $n) = @_;

    my $s = 0;
    my $code = $self->{code};
    for my $i (1..5) {
        my $t0 = time;
        $code->($n);
        $s += time - $t0;
    };
    return $s/5; # TODO remove hardcode, return 0 if too shaky data
};

sub infer_linear {
    my $self = shift;
    my $data = shift || $self->{data};

    my @steps = sort { $a <=> $b } keys %$data;
    my @times = @$data{@steps};

    my @points;
    for (my $i = @steps-1; $i-->0; ) {
        push @points, ( ($times[$i+1] - $times[$i]) 
                      / ($steps[$i+1] - $steps[$i]) ); 
    };

    return _average( \@points );
};

sub _average {
    my ($data) = @_;

    my ($sum, $sum2) = (0,0);

    $sum    += $_ for @$data;
    $sum2   += $_*$_ for @$data;

    my $avg  = $sum / @$data;
    my $disp = sqrt( ($sum2 - $sum * $sum / @$data) / (@$data - 1) );

    return ( $avg, $disp );
};

sub _croak {
    my ($self, $msg) = @_;

    my @stack = caller(1);
    my $fun = $stack[3];
    $fun =~ s/^.*:://;

    croak (ref $self || $self)."->$fun(): $msg";
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
