package MessageBus::Sub;

use strict;
use base qw/Class::Accessor::Fast/;

__PACKAGE__->mk_accessors(qw/chan _pubs _cache/);

sub new {
    my ($class, $cache, @chan) = @_;
    my $pubs = { map { $_ => $cache->publisher_indices($_); } @chan };
    my $self = bless({ chan => \@chan, _cache => $cache, _pubs => $pubs });
    return $self;
}

sub get_all {
    my $self = shift;
    my $pubs = $self->_pubs;
    my $cache = $self->_cache;
    return {
        map {
            my $orig = $pubs->{$_};
            $pubs->{$_} = $cache->publisher_indices($_);
            $_ => [$cache->get($_, $orig, $pubs->{$_})];
        } @{$self->chan}
    };
}

sub get {
    my $self = shift;
    my $pubs = $self->_pubs;
    my $cache = $self->_cache;
    my $chan = @_ ? shift : $self->chan->[0];

    my $orig = $pubs->{$chan};
    $pubs->{$chan} = $cache->publisher_indices($chan);
    wantarray
        ? map {$_->[1]} $cache->get($chan, $orig, $pubs->{$chan})
        : [map {$_->[1]} $cache->get($chan, $orig, $pubs->{$chan})];
}

1;
