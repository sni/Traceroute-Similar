#!/usr/bin/env perl
#
# $Id$
#
use Test::More;

BEGIN {
  eval {require Net::Traceroute;};

  if ( $@ ) {
    plan skip_all => 'Net::Traceroute not installed'
  }else{
    plan tests => 2
  }
}

use_ok("Traceroute::Similar");
my $ts = Traceroute::Similar->new({'backend' => 'Net::Traceroute'});

my $expected_routes = [ { 'name' => '', 'addr' => '127.0.0.1' } ];
my $local_route = $ts->_get_route_for_host('localhost');
is_deeply($expected_routes, $local_route, 'route for localhost');