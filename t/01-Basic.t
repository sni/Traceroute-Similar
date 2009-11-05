#!/usr/bin/env perl

#########################

use strict;
use Sys::Hostname;
use Test::More tests => 3;
BEGIN {
    use_ok('Traceroute::Similar')
};

#########################

my $ts = Traceroute::Similar->new( verbose => 0 );
isa_ok( $ts, 'Traceroute::Similar' );

SKIP: {
    skip 'no backend found', 1,if(!defined $ts->get_backend());
    my $last_common_hop1 = $ts->get_last_common_hop('localhost', hostname);
    is($last_common_hop1, undef, 'Example 1');
}
