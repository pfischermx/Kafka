package Kafka::Message;

# WARNING: in order to achieve better performance,
# methods of this module do not perform arguments validation

#-- Pragmas --------------------------------------------------------------------

use 5.010;
use strict;
use warnings;

# ENVIRONMENT ------------------------------------------------------------------

our $VERSION = '0.800_1';

#-- load the modules -----------------------------------------------------------

#-- declarations ---------------------------------------------------------------

our @_standard_fields = qw(
    Attributes
    error
    HighwaterMarkOffset
    key
    MagicByte
    next_offset
    payload
    offset
    valid
);

#-- constructor ----------------------------------------------------------------

sub new {
    my ( $class, $self ) = @_;

    bless $self, $class;

    return $self;
}

#-- public attributes ----------------------------------------------------------

{
    no strict 'refs';   ## no critic

    # getters
    foreach my $method ( @_standard_fields )
    {
        *{ __PACKAGE__.'::'.$method } = sub {
            my ( $self ) = @_;
            return $self->{ $method };
        };
    }
}

#-- public methods -------------------------------------------------------------

#-- private attributes ---------------------------------------------------------

#-- private methods ------------------------------------------------------------

#-- Closes and cleans up -------------------------------------------------------

1;

__END__

=head1 NAME

Kafka::Message - object interface to the Kafka message properties

=head1 VERSION

This documentation refers to C<Kafka::Message> version 0.800_1

=head1 SYNOPSIS

    use 5.010;
    use strict;

    use Kafka qw(
        $DEFAULT_MAX_BYTES
    );
    use Kafka::Connection;
    use Kafka::Consumer;

    #-- Connection
    my $connect = Kafka::Connection->new( host => 'localhost' );

    #-- Consumer
    my $consumer = Kafka::Consumer->new( Connection  => $connect );

    # The Kafka consumer response has an ARRAY reference type.
    # For the fetch response array has the class name Kafka::Message elements.

    # Consuming messages
    my $messages = $consumer->fetch(
        'mytopic',          # topic
        0,                  # partition
        0,                  # offset
        $DEFAULT_MAX_BYTES  # Maximum size of MESSAGE(s) to receive
    );
    if ( $messages ) {
        foreach my $message ( @$messages ) {
            if( $message->valid ) {
                say 'key        : ', $message->key;
                say 'payload    : ', $message->payload;
                say 'offset     : ', $message->offset;
                say 'next_offset: ', $message->next_offset;
            }
            else {
                say 'error      : ', $message->error;
            }
        }
    }

=head1 DESCRIPTION

L<Kafka|Kafka> message API is implemented by L<Kafka::Message|Kafka::Message> class.

The C<Kafka::Message> module in L<Kafka|Kafka> package provides an object
oriented access to the message properties.
Reference to an array of objects of class C<Kafka::Message> returned by the
C<fetch> method of the L<Consumer|Kafka::Consumer> client.
Package L<Kafka|Kafka> C<Kafka::Message> class is not otherwise used.

The main features of the C<Kafka::Message> class are:

=over 3

=item *

Provides representing the Apache Kafka Wire Format MESSAGE structure (with
no compression codec attribute now). Description of the structure is available at
L<http://cwiki.apache.org/confluence/display/KAFKA/Wire+Format/>

=item *

Support for working with 64 bit elements on 32 bit systems.
C<offset> and C<next_offset> methods return the
L<Math::BigInt|Math::BigInt> integer on 32 bit systems.

=back

=head2 CONSTRUCTOR

=head3 C<new ( \%arg )>

Creates a C<Kafka::Message>, which is a newly created message object.
C<new()> takes an argument, this argument is a HASH reference with the currently
used L<methods|/METHODS> entries.

Returns the created message as a C<Kafka::Message> object, or error will
cause the program to halt (C<confess>) if the argument is not a valid HASH
reference.

=head2 METHODS

The following methods are available for each C<Kafka::Message> object and are
specific to that object and the method calls invoked on it.

The available methods for objects of the C<Kafka::Message>
class are:

=head3 C<payload>

A simple message received from the Apache Kafka server.

=head3 C<valid>

A message entry is valid if the CRC32 of the message C<payload> matches
to the CRC stored with the message.

=head3 C<error>

A description of the message inconsistence (currently only for when
message is not valid or is compressed).

=head3 C<offset>

The offset beginning of the message in the Apache Kafka server.

=head3 C<next_offset>

The offset beginning of the next message in the Apache Kafka server.

=head3 C<Attributes>

blah-blah-blah

=head3 C<HighwaterMarkOffset>

blah-blah-blah

=head3 C<MagicByte>

blah-blah-blah

=head3 C<key>

blah-blah-blah

=head1 DIAGNOSTICS

C<Kafka::Message> is not a user module and any L<constructor|/CONSTRUCTOR> error
is FATAL.
FATAL errors will cause the program to halt (C<confess>), since the
problem is so severe that it would be dangerous to continue. (This
can always be trapped with C<eval>. Under the circumstances, dying is the best
thing to do).

=over 3

=item C<Invalid argument>

This means that you didn't give the right argument to a C<new>
L<constructor|/CONSTRUCTOR>, i.e. not a raw and unblessed HASH reference,
or a HASH key doesn't have valid L<methods|/METHODS> name, or not C<defined>
value.

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
