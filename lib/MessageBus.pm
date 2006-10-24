package MessageBus;
$MessageBus::VERSION = '0.01';

use 5.005;
use strict;
use Class::InsideOut qw( public private register id );
use MessageBus::Pub;
use MessageBus::Sub;

private cache  => my %cache;

sub new {
    my $id = id( my $self = register( bless \(my $s), shift ) );

    my $backend = shift || 'PlainHash';

    local $@;
    eval { require "MessageBus/Cache/$_.pm" }
        or die "Cannot find backend module: MessageBus::Cache::$_";

    $cache{$id} = "MessageBus::Cache::$_"->new(@_);
    return $self;
}

sub publish {
    my $id   = id(my $self = shift);
    MessageBus::Pub->new($cache{$id}, @_ ? @_ : '');
}

sub subscribe {
    my $id   = id(my $self = shift);
    MessageBus::Sub->new($cache{$id}, @_ ? @_ : '');
}

1;

__END__

=head1 NAME

MessageBus - Lightweight publish/subscribe messaging system

=head1 SYNOPSIS

    # A new message bus with the DBM::Deep backend
    # (Other possible backends include Memcached and PlainHash)
    my $bus = MessageBus->new(DBM_Deep => '/tmp/bus.db');

    # A channel is any arbitrary string
    my $channel = '#perl6';

    # Register a new publisher (you can publish to multiple channels)
    my $pub = $bus->publish("#perl6", "#moose");

    # Publish a message (may be a complex object) to those channels
    $pub->msg("This is a message");

    # Register a new subscriber (you can subscribe to multiple channels)
    my $sub = $bus->subscribe("#moose");

    # Publish an object to channels
    $pub->msg("This is another message");

    # Simple get: Returns the messages sent since the previous get,
    # but only for the first channel.
    my @msgs = $sub->get;

    # Simple get, with an explicit channel key (must be among the ones
    # it initially subscribed to)
    my @msgs = $sub->get("#moose");

    # Complex get: Returns a hash reference from channels to array
    # references of [timestamp, message].
    my $hash_ref = $sub->get_all;

=head1 DESCRIPTION

This module provides a simple message bus for publishing messages and
subscribing to them.

Currently it offers three backends: C<DBM_Deep> for on-disk storage,
C<Memcached> for possibly multi-host storage, and C<PlainHash> for
single-process storage.

Please see the tests in F<t/> for this distribution, as well as L</SYNOPSIS>
above, for some usage examples; detailed documentation is not yet available.

=head1 AUTHORS

Audrey Tang E<lt>cpan@audreyt.orgE<gt>

=head1 COPYRIGHT (The "MIT" License)

Copyright 2002-2006 by Audrey Tang <cpan@audreyt.org>.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is fur-
nished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FIT-
NESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE X
CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=cut
