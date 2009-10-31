#!/usr/bin/env perl
#
# $Id$
#
use Test::More tests => 1;

use_ok("Traceroute::Similar");
my $ts = Traceroute::Similar->new({'backend' => 'traceroute'});