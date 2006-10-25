package MessageBus::Pub;
use strict;
use Data::UUID;
use base qw/Class::Accessor::Fast/;

__PACKAGE__->mk_accessors(qw/chan _uuid _cache/);

sub new {
    my ($class, $cache, @chan) = @_;
    my $uuid = Data::UUID->new->create_b64;
    my $self = bless({ _cache => $cache, chan => \@chan, _uuid => $uuid });
    $cache->add_publisher($_, $uuid) for @chan;
    return $self;
}

sub msg {
    my $self = shift;
    my $msg = shift;
    $self->_cache->put($_, $self->_uuid, $msg) for @{$self->chan};
}

no warnings 'redefine';
sub DESTROY {
    my $self = shift;
    $self->_cache->remove_publisher($_, $self->_cache) for @{$self->chan};
}

1;
