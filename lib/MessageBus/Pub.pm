package MessageBus::Pub;
use strict;
use Data::UUID;
use Class::InsideOut qw( public private register id );

public  chan    => my %chan;
private uuid    => my %uuid;
private cache   => my %cache;

sub new {
    my ($class, $cache, @chan) = @_;
    my $id = id( my $self = register( bless \(my $s), shift ) );
    $chan{$id} = \@chan;
    $uuid{$id} = Data::UUID->new->create_b64;
    $cache{$id} = $cache;
    $cache->add_publisher($_, $uuid{$id}) for @chan;
    return $self;
}

sub msg {
    my $id  = id(my $self = shift);
    my $msg = shift;
    $cache{$id}->put($_, $uuid{$id}, $msg) for @{$chan{$id}};
}

no warnings 'redefine';
sub DESTROY {
    my $id  = id(my $self = shift);
    $cache{$id}->remove_publisher($_, $uuid{$id}) for @{$chan{$id}};
}

1;
