#!/usr/bin/perl

use strict;
use warnings;
use feature qw(say);

$, = shift // ': ';
my ($ifname, %dhcp);
foreach my $con (`nmcli -g NAME connection show --active`) {
    foreach (`nmcli -f GENERAL,DHCP4 connection show $con`) {
        my @data   = split;
        $ifname = $data[-1] if $data[0] eq qw(GENERAL.NAME:);
        $dhcp{$ifname} = $data[-1] if $data[1] eq qw(dhcp_server_identifier);
    }
}
say $_, $dhcp{$_} foreach sort keys %dhcp;
