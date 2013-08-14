package Kafka::Int64;

# Transparent BigInteger support on 32-bit platforms where native integer type is
# limited to 32 bits and slow bigint must be used instead. Use subs from this module
# in such case.

# WARNING: in order to achieve better performance,
# methods of this module do not perform arguments validation

#-- Pragmas --------------------------------------------------------------------

use 5.010;
use strict;
use warnings;

use bigint; # this allows integers of practially any size at the cost of significant performance drop

# ENVIRONMENT ------------------------------------------------------------------

use Exporter qw(
    import
);

our @EXPORT_OK = qw(
    intsum
    packq
    unpackq
);

our $VERSION = '0.800_1';

#-- load the modules -----------------------------------------------------------

use Carp;

use Kafka qw(
    %ERROR
    $ERROR_MISMATCH_ARGUMENT
);

#-- declarations ---------------------------------------------------------------

#-- public functions -----------------------------------------------------------

sub intsum {
    my ( $frst, $scnd ) = @_;

    my $ret = $frst + $scnd + 0;    # bigint coercion
    confess $ERROR{ $ERROR_MISMATCH_ARGUMENT }
        if $ret->is_nan();

    return $ret;
}

sub packq {
    my ( $n ) = @_;

    if      ( $n == -1 )    { return pack q{C8}, ( 255 ) x 8; }
    elsif   ( $n == -2 )    { return pack q{C8}, ( 255 ) x 7, 254; }
    elsif   ( $n < 0 )      { confess $ERROR{ $ERROR_MISMATCH_ARGUMENT }; }

    return pack q{H16}, substr( '00000000000000000000000000000000'.substr( ( $n + 0 )->as_hex(), 2 ), -16 );
}

sub unpackq {
    my ( $s ) = @_;

    return Math::BigInt->from_hex( '0x'.unpack( q{H16}, $s ) );
}

#-- private functions ----------------------------------------------------------

1;

__END__

=head1 NAME

Kafka::Int64 - functions to work with 64 bit elements of
the Apache Kafka Wire Format protocol on 32 bit systems

=head1 VERSION

This documentation refers to C<Kafka::Int64> version 0.800_1

=head1 SYNOPSIS

    use 5.010;
    use strict;

    use Kafka qw(
        $BITS64
    );

    # Apache Kafka Protocol: FetchOffset, Time

    my $offset = 123;

    my $encoded = $BITS64 ?
        pack( 'q>', $offset )
        : Kafka::Int64::packq( $offset );

    my $response = chr( 0 ) x 8;

    $offset = $BITS64 ?
        unpack( 'q>', substr( $response, 0, 8 ) )
        : Kafka::Int64::unpackq( substr( $response, 0, 8 ) );

    my $next_offset;
    if ( $BITS64 ) {
        $next_offset = $offset + 1;
    }
    else {
        $next_offset = Kafka::Int64::intsum( $offset, 1 );
    }

=head1 DESCRIPTION

Transparent L<BigInteger|bigint> support on 32-bit platforms where native
integer type is limited to 32 bits and slow bigint must be used instead.
Use L<functions|/FUNCTIONS> from this module in such case.

The main features of the C<Kafka::Int64> module are:

=over 3

=item *

Support for working with 64 bit elements of the Kafka Wire Format protocol
on 32 bit systems.

=back

=head2 FUNCTIONS

The following functions are available for the C<Kafka::Int64> module.

=head3 C<intsum( $bint, $int )>

Adds two numbers to emulate bigint adding 64-bit integers in 32-bit systems.

The both arguments must be a number. That is, it is defined and Perl thinks
it's a number. The first argument may be a L<Math::BigInt|Math::BigInt>
integer.

Returns the value as a L<Math::BigInt|Math::BigInt> integer, or error will
cause the program to halt (C<confess>) if the argument is not a valid number.

=head3 C<packq( $bint )>

Emulates C<pack( "qE<gt>", $bint )> to 32-bit systems - assumes decimal string
or integer input.

An argument must be a positive number. That is, it is defined and Perl thinks
it's a number. The argument may be a L<Math::BigInt|Math::BigInt> integer.

The special values -1, -2 are allowed.

Returns the value as a packed binary string, or error will cause the program
to halt (C<confess>) if the argument is not a valid number.

=head3 C<unpackq( $bstr )>

Emulates C<unpack( "qE<gt>", $bstr )> to 32-bit systems - assumes binary input.

The argument must be a binary string of 8 bytes length.

Returns the value as a L<Math::BigInt|Math::BigInt> integer, or error will
cause the program to halt (C<confess>) if the argument is not a valid binary
string.

=head1 DIAGNOSTICS

C<Kafka::Int64> is not a user module and any L<functions|/FUNCTIONS> error
is FATAL.
FATAL errors will cause the program to halt (C<confess>), since the
problem is so severe that it would be dangerous to continue. (This can
always be trapped with C<eval>. Under the circumstances, dying is the best
thing to do).

=over 3

=item C<Invalid argument>

This means that you didn't give the right argument to some of the
L<functions|/FUNCTIONS>.

=back

=head1 SEE ALSO

The basic operation of the Kafka package modules:

L<Kafka|Kafka> - constants and messages used by the Kafka package modules

L<Kafka::IO|Kafka::IO> - object interface to socket communications with
the Apache Kafka server

L<Kafka::Producer|Kafka::Producer> - object interface to the producer client

L<Kafka::Consumer|Kafka::Consumer> - object interface to the consumer client

L<Kafka::Message|Kafka::Message> - object interface to the Kafka message
properties

L<Kafka::Protocol|Kafka::Protocol> - functions to process messages in the
Apache Kafka's wire format

L<Kafka::Int64|Kafka::Int64> - functions to work with 64 bit elements of the
protocol on 32 bit systems

L<Kafka::Mock|Kafka::Mock> - object interface to the TCP mock server for testing

A wealth of detail about the Apache Kafka and Wire Format:

Main page at L<http://incubator.apache.org/kafka/>

Wire Format at L<http://cwiki.apache.org/confluence/display/KAFKA/Wire+Format/>

Writing a Driver for Kafka at
L<http://cwiki.apache.org/confluence/display/KAFKA/Writing+a+Driver+for+Kafka>

=head1 AUTHOR

Sergey Gladkov, E<lt>sgladkov@trackingsoft.comE<gt>

=head1 CONTRIBUTORS

Alexander Solovey

Jeremy Jordan

Vlad Marchenko

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012-2013 by TrackingSoft LLC.

This package is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See I<perlartistic> at
L<http://dev.perl.org/licenses/artistic.html>.

This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
