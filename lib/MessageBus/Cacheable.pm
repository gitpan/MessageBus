package MessageBus::Cacheable;
use strict;
use Time::HiRes 'time';

#method fetch                (Str *@keys --> List of Pair)                   { ... }
#method store                (Str $key, Str $val, Num $time, Num $expiry)    { ... }

#method add_publisher        (Str $chan, Str $pub)                           { ... }
#method remove_publisher     (Str $chan, Str $pub)                           { ... }

#method get_index            (Str $chan, Str $pub --> Int)                   { ... }
#method set_index            (Str $chan, Str $pub, Int $index)               { ... }

#method publisher_indices    (Str $chan --> Hash of Int)                     { ... }

sub get {
    my ($self, $chan, $orig, $curr) = @_;

    no warnings 'uninitialized';
    sort { $a->[0] <=> $b->[0] } $self->fetch(
        map {
            my $pub = $_;
            my $index = $curr->{$pub};
            map {
                "$chan-$pub-$_"
            } (($orig->{$pub}+1) .. $index);
        } keys(%$curr)
    );
}

sub put {
    my ($self, $chan, $pub, $msg, $expiry) = @_;
    my $index = 1 + $self->get_index($chan, $pub);
    $self->store("$chan-$pub-$index", $msg, time, $expiry);
    $self->set_index($chan, $pub, $index);
}

1;
