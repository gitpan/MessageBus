package MessageBus::Sub;

use strict;
use Class::InsideOut qw( public private register id );

public  chan    => my %chan;
private pubs    => my %pubs;
private cache   => my %cache;

sub new {
    my ($class, $cache, @chan) = @_;
    my $id = id( my $self = register( bless \(my $s), shift ) );
    $pubs{$id}  = { map { $_ => $cache->publisher_indices($_); } @chan };
    $cache{$id} = $cache;
    $chan{$id}  = \@chan;
    return $self;
}

sub get_all {
    my $id = id(my $self = shift);
    return {
        map {
            my $orig = $pubs{$id}{$_};
            $pubs{$id}{$_} = $cache{$id}->publisher_indices($_);
            $_ => [$cache{$id}->get($_, $orig, $pubs{$id}{$_})];
        } @{$chan{$id}}
    };
}

sub get {
    my $id   = id(my $self = shift);
    my $chan = @_ ? shift : $chan{$id}[0];

    my $orig = $pubs{$id}{$chan};
    $pubs{$id}{$chan} = $cache{$id}->publisher_indices($chan);
    wantarray
        ? map {$_->[1]} $cache{$id}->get($chan, $orig, $pubs{$id}{$chan})
        : [map {$_->[1]} $cache{$id}->get($chan, $orig, $pubs{$id}{$chan})];
}

1;
