#!/usr/bin/env perl
#
# $Id$
#
use Test::More tests => 3;


use_ok("Traceroute::Similar");
my $ts = Traceroute::Similar->new( verbose => 0 );
isa_ok( $ts, 'Traceroute::Similar' );

SKIP: {
    skip 'no backend found', 1,if(!defined $ts->get_backend());

    $ts = Traceroute::Similar->new('backend' => 'traceroute');

    my $expected_routes = [ { 'name' => 'localhost', 'addr' => '127.0.0.1' } ];
    my $local_route = $ts->_get_route_for_host('localhost');
    is_deeply($expected_routes, $local_route, 'route for localhost');
}