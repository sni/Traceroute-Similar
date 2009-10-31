#!/usr/bin/env perl
#
# $Id$
#
use Test::More;

BEGIN {
  eval {require Net::Traceroute::PurePerl;};

  if ( $@ ) {
    plan skip_all => 'Net::Traceroute::PurePerl not installed'
  }else{
    plan tests => 1
  }
}

use_ok("Traceroute::Similar");
my $ts = Traceroute::Similar->new({'backend' => 'Net::Traceroute::PurePerl'});