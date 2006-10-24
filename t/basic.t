use strict;
use Test::More tests => 18;
use MessageBus;
use IO::Socket::INET;

my @backends = qw(PlainHash DBM_Deep Memcached);

SKIP: for (@backends) {
    if ($_ eq 'Memcached') {
        my $sock = IO::Socket::INET->new('127.0.0.1:11211')
            or skip("Memcached not started", 6);
    }

    my $bus = MessageBus->new($_);

    my @sub; $sub[0] = $bus->subscribe;

    is_deeply([map {$_->[1]} @{$sub[0]->get_all->{''}}], [], 'get_all worked when there is no pubs');
    is_deeply([$sub[0]->get], [], 'get_all worked when there is no pubs');

    my $pub = $bus->publish;

    $pub->msg('foo');

    $sub[1] = $bus->subscribe;

    $pub->msg('bar');
    $pub->msg('baz');

    is_deeply([$sub[0]->get], [qw< foo bar baz >], 'get worked');
    is_deeply([$sub[0]->get], [], 'get emptied the cache');

    is_deeply([map {$_->[1]} @{$sub[1]->get_all->{''}}], [qw< bar baz >], 'get_all worked');
    is_deeply([map {$_->[1]} @{$sub[1]->get_all->{''}}], [], 'get_all emptied the cache');
}
