package MessageBus::Cache::JiftyDBI;
use strict;
use base 'MessageBus::Cacheable';
use MessageBus::Cache::JiftyDBI::Stash;
my %cache;

use vars qw/$STASH/;

sub new {
    my $class = shift;
    my $self = {};
    bless $self => $class;
    $STASH ||= MessageBus::Cache::JiftyDBI::Stash->new(@_);

   return $self; 
}



sub fetch {
    my $self  = shift;
    my @keys_in_order = (@_);
    my $items = MessageBus::Cache::JiftyDBI::Stash::ItemCollection->new( handle => $STASH->handle );
    foreach my $val (@keys_in_order) {
        $items->limit(
            column           => 'key',
            entry_aggregator => 'or',
            value            => $val
        );
    }

    my %items = map { $_->key, [$_->expiry, $_->val] } @{ $items->items_array_ref };
    return @items{@keys_in_order};
}

sub store {
    my ($self, $key, $val, $time, $expiry) = @_;
    $expiry ||= 0;
    my $item = MessageBus::Cache::JiftyDBI::Stash::Item->new(handle => $STASH->handle);
    $item->create( key => $key, expiry => ($time+$expiry), val => $val);
}

sub publisher_indices {
    my ($self, $chan) = @_;
    my $publishers = MessageBus::Cache::JiftyDBI::Stash::PublisherCollection->new(handle => $STASH->handle);
    $publishers->limit(column => 'channel', value => $chan);
    
    my %indices;
    map {$indices{$_->name} = $_->idx} @{$publishers->items_array_ref};
    return \%indices;

}

sub add_publisher {
    my ($self, $chan, $pub) = @_;

    my $publisher = MessageBus::Cache::JiftyDBI::Stash::Publisher->new(handle => $STASH->handle);
    $publisher->create( channel => $chan, name => $pub, idx => 0);

}

sub remove_publisher {
    my ($self, $chan, $pub) = @_;
    my $publisher = _get_publisher($chan => $pub);
    $publisher->delete();

}

sub get_index {
    my ($self, $chan, $pub) = @_;
    my $publisher =  _get_publisher($chan => $pub);
    if ($publisher->id) {
            return $publisher->idx
        }
    
}

sub set_index {
    my ($self, $chan, $pub, $idx) = @_;
    return _get_publisher($chan => $pub)->set_idx($idx);
}

sub _get_publisher {
    my $chan = shift;
    my $pub = shift;
    my $publisher = MessageBus::Cache::JiftyDBI::Stash::Publisher->new(handle => $STASH->handle);
    $publisher->load_by_cols( channel => $chan, name => $pub);
    return $publisher;
}
1;
