#!/usr/bin/env perl
#
# vim:ts=4:sw=4:expandtab

package Traceroute::Similar;

use 5.008008;
use strict;
use warnings;
use Carp;

our $VERSION = '0.11';

########################################
sub new {
    my $class   = shift;
    my $options = shift;
    my $self = {
                    "verbose"   => 0,
                    "backend"   => undef,
               };
    bless $self, $class;

    $self->{'verbose'} = $options->{'verbose'} if defined $options->{'verbose'};

    # which backend do we use?
    $self->{'backend'} = $options->{'backend'}     if defined $options->{'backend'};
    $self->{'backend'} = $self->_detect_backend() unless defined $self->{'backend'};

    if(!defined $self->{'backend'}) {
        croak("No backend found, please install one of Net::Traceroute or Net::Traceroute::PurePerl. Or make sure your traceroute binary is in your path.");
    }

    return $self;
}

########################################
sub get_last_common_hop {
    my $self  = shift;
    my $routes;
    while(my $host = shift) {
        $routes->{$host} = $self->_get_route_for_host($host);
    }

    return($self->_calculate_last_common_hop($routes))
}

########################################
sub _calculate_last_common_hop {
    my $self   = shift;
    my $routes = shift;

    my @hostnames = keys %{$routes};
    if(scalar @hostnames <= 1) { croak("need at least 2 hosts to calculate similiar routes"); }

    my $last_common_addr = undef;
    for(my $x = 0; $x <= scalar(@{$routes->{$hostnames[0]}}); $x++) {
        my $current_hop = $routes->{$hostnames[0]}->[$x]->{'addr'};
        for my $host (@hostnames) {
            if(!defined $routes->{$host}->[$x]->{'addr'} or $current_hop ne $routes->{$host}->[$x]->{'addr'}) {
                return $last_common_addr;
            }
        }
        $last_common_addr = $current_hop;
    }

    return($last_common_addr);
}

########################################
sub _get_route_for_host {
    my $self = shift;
    my $host = shift;
    my $routes;

    print "DEBUG: _get_route_for_host('".$host."')\n" if $self->{'verbose'};

    if($self->{'backend'} eq 'traceroute') {
        my $cmd = "traceroute $host";
        print "DEBUG: cmd: $cmd\n" if $self->{'verbose'};
        open(my $ph, "-|", "$cmd 2>&1") or confess("cmd failed: $!");
        my $output;
        while(<$ph>) {
            my $line = $_;
            $output .= $line;
            print "DEBUG: traceroute: $line" if $self->{'verbose'};
        }
        close($ph);
        my $rt = $?>>8;
        print "DEBUG: return code from traceroute: $rt\n" if $self->{'verbose'};

        if($rt == 0) {
            $routes = $self->_extract_routes_from_traceroute($output);
        }
    }
    elsif($self->{'backend'} eq 'Net::Traceroute') {
        my $tr = Net::Traceroute->new(host=> $host);
        my $hops = $tr->hops;
        my $last_hop;
        for(my $x = 0; $x <= $hops; $x++) {
            my $cur_hop = $tr->hop_query_host($x, 0);
            if(defined $cur_hop and (!defined $last_hop or $last_hop ne $cur_hop)) {
                push @{$routes}, { 'addr' => $cur_hop, 'name' => '' };
                $last_hop = $cur_hop;
            }
        }
    }
    elsif($self->{'backend'} eq 'Net::Traceroute::PurePerl') {
        my $tr = new Net::Traceroute::PurePerl( host => $host );
        $tr->traceroute;
        my $hops = $tr->hops;
        my $last_hop;
        for(my $x = 0; $x <= $hops; $x++) {
            my $cur_hop = $tr->hop_query_host($x, 0);
            if(defined $cur_hop and (!defined $last_hop or $last_hop ne $cur_hop)) {
                push @{$routes}, { 'addr' => $cur_hop, 'name' => '' };
                $last_hop = $cur_hop;
            }
        }
    }
    else {
        croak("unknown backend: ".$self->{'backend'});
    }

    return $routes;
}

########################################
sub _extract_routes_from_traceroute {
    my $self   = shift;
    my $output = shift;
    my @routes;

    for my $line (split /\n/, $output) {
        if($line =~ m/(\d+)\s+(.*?)\s+\((\d+\.\d+\.\d+\.\d+)\)/) {
            push @routes, { 'addr' => $3, 'name' => $2 };
        }
    }

    return(\@routes);
}

########################################
sub _detect_backend {
    my $self = shift;

    print "DEBUG: detecting backend\n" if $self->{'verbose'};

    # try to load Net::Traceroute:PurePerl
    eval {
        require Net::Traceroute::PurePerl;
        print "DEBUG: using Net::Traceroute::PurePerl as backend\n" if $self->{'verbose'};
        return("Net::Traceroute::PurePerl");
    };

    # try to load Net::Traceroute
    eval {
        require Net::Traceroute;
        print "DEBUG: using Net::Traceroute as backend\n" if $self->{'verbose'};
        return("Net::Traceroute");
    };

    # try to use traceroute
    my $traceroute_bin = qx{which traceroute};
    if(defined $traceroute_bin) {
        print "DEBUG: found traceroute in path: $traceroute_bin\n" if $self->{'verbose'};
        return('traceroute');
    }
}

########################################

1;
__END__

=head1 NAME

Traceroute::Similar - Perl extension for looking up common hops

=head1 SYNOPSIS

  use Traceroute::Similar;
  my $ts = Traceroute::Similar->new();
  print $ts->get_last_common_hop('host1.com', 'host2.org');

=head1 DESCRIPTION

This module calculates the furthest common hop from a list of host. The backend
will be Net::Traceroute:PurePerl or Net::Traceroute or system
tracerroute (sometimes root or sudo permission required).


=head1 AUTHOR

Sven Nierlein, E<lt>sven@nierlein.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Sven Nierlein

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.9 or,
at your option, any later version of Perl 5 you may have available.


=cut
